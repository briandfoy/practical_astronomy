use v5.26;
use utf8;
use Test2::V0;
use Test2::Tools::Warnings qw/warns warning warnings no_warnings/;

use open qw(:std :utf8);
use experimental qw(signatures);


use File::FindLib qw(lib);
use Mojo::Util qw(dumper);

my $planets;

subtest planets_data => sub {
	my $class     = 'PracticalAstronomy::PlanetsData';
	my $data_file = 'data/planetary_data_2010.json';
	ok( eval "use $class; 1", "Class $class loads" ) or diag( $@ );
	ok( -e $data_file, "Data file <$data_file> exists" );
	$planets = $class->new_from_file( $data_file );
	} or BAIL_OUT();

my $class     = 'PracticalAstronomy::Planet';
my @methods   = qw(
	days_since_epoch
	orbital_period
	eccentricity
	long_at_perihelion
	long_at_epoch
	orbital_inclination
	long_of_ascending_node
	semi_major_axis
	angular_diameter_1au
	visual_magnitude_1au
	mean_anomaly
	true_anomaly
	heliocentric_anomaly
	radius_vector
	eccentric_anomaly
	);

subtest load_planet => sub {
	my $planet = $planets->data_for( 'mercury' );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );
	} or BAIL_OUT();

use Mojo::Util qw(dumper);
subtest methods => sub {
	my $planet = $planets->data_for( 'venus' );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->name,                   'Venus',     'name for Venus'                   );
	is( $planet->symbol,                 '♀',         'symbol for Venus'                 );
	is( $planet->orbital_period,         '0.615207',  'orbital_period (Tp) for Venus'    );
	is( $planet->eccentricity,           '0.006812',  'eccentricity for Venus'           );
	is( $planet->long_at_perihelion,     '131.54',    'ω, long_at_perihelion for Venus'  );
	is( $planet->long_at_epoch,          '272.30044', 'ε, long_at_epoch for Venus'       );
	is( $planet->orbital_inclination,    '3.3947',    'orbital_inclination for Venus'    );
	is( $planet->long_of_ascending_node, '76.769',    'long_of_ascending_node for Venus' );
	is( $planet->semi_major_axis,        '0.723329',  'semi_major_axis for Venus'        );
	is( $planet->angular_diameter_1au,   '16.92',     'angular_diameter_1au for Venus'   );
	is( $planet->visual_magnitude_1au,   '-4.40',     'visual_magnitude_1au for Venus'   );
	};

sub test_plain ( $plain ) {
	isa_ok( $plain, $class );
	can_ok( $plain, @methods );
	ok( ! $plain->date_is_set, "Date is not set in plain object" );
	}

subtest plain => sub {
	my $plain = $planets->data_for( 'Uranus' );
	test_plain( $plain );

	my @computing_methods = qw(
		days_since_epoch
		Np mean_anomaly true_anomaly eccentric_anomaly
		heliocentric_anomaly radius_vector heliocentric_latitude
		);

	foreach my $method ( @computing_methods ) {
		ok( ! $plain->date_is_set, "Date is not set in plain object" );

		my $rc = do {
			local *STDERR;
			open STDERR, '>', \my $warning;
			[ $plain->$method() // undef, $warning ];
			};

		ok( ! defined $rc->[0], "Method <$method> for plain object returns undef" )
			or diag( "$method returned <$rc->[0]>" );
		like( $rc->[1], qr/\ADate not set/, "Method <$method> for plain object warns" );
		}
	};

# page 126
subtest jupiter_anomalies => sub {
	my $name = 'Jupiter';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my( $y, $m, $d ) = qw( 2003 11 22 );
	my $planet = $plain->clone_with_date( $y, $m, $d );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->days_since_epoch, -2231, "-2231 days to $y-$m-$d" );

	is( sprintf( '%.6f', $planet->Np ), '174.555932', 'Np is correct' );

	is( sprintf( '%.6f', $planet->mean_anomaly ), '497.809764', "mean_anomaly for $name" );
	is( sprintf( '%.6f', $planet->true_anomaly ), '141.573600', "true_anomaly for $name" );

	is( sprintf( '%.6f', $planet->heliocentric_anomaly ), '156.236900', "heliocentric_anomaly for $name" );
	is( sprintf( '%.6f', $planet->radius_vector ), '5.397121', "radius_vector for $name" );
	};

# page 126
subtest earth_anomalies => sub {
	my $name = 'Earth';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my( $y, $m, $d ) = qw( 2003 11 22 );
	my $planet = $plain->clone_with_date( $y, $m, $d );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->days_since_epoch, -2231, "-2231 days to $y-$m-$d" );

	is( $planet->Np, '321.011952', 'Np is correct' );

	# book says 317.363223, but that's a round off error
	is( $planet->mean_anomaly, '317.363224', "mean_anomaly for $name" );
	is( $planet->true_anomaly, '316.069248', "true_anomaly for $name" );

	is( $planet->heliocentric_anomaly, '59.274748', "heliocentric_anomaly for $name" );
	is( $planet->radius_vector, '0.987847', "radius_vector for $name" );
	};

subtest eccentric_anomaly => sub {
	my $name = 'Mars';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my( $y, $m, $d ) = qw( 2003 11 22 );
	my $planet = $plain->clone_with_date( $y, $m, $d );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	diag( "Mars mean anomaly: " . $planet->mean_anomaly );
	diag( "Mars true anomaly: " . $planet->true_anomaly );

	my $E = $planet->eccentric_anomaly;
	# I have not verified this result, but it's between the mean and
	# true anomaly: M 43.685408 ν 51.073733
	is( $E, '47.637347', 'eccentric_anomaly for Mars' );
	};

# page 136
subtest distance_to_jupiter => sub {
	my( $y, $m, $d ) = qw( 2003 11 22 );

	my $earth = $planets->data_for( 'Earth' )->clone_with_date( $y, $m, $d );
	isa_ok( $earth, $class );
	can_ok( $earth, qw(radius_vector heliocentric_anomaly) );
	is( $earth->radius_vector, '0.987847', 'Radius to Earth' );
	is( $earth->heliocentric_anomaly, '59.274748', 'Heliocentric anomaly for Earth' );

	my $jupiter = $planets->data_for( 'Jupiter' )->clone_with_date( $y, $m, $d );
	isa_ok( $jupiter, $class );
	can_ok( $jupiter, qw(radius_vector heliocentric_anomaly heliocentric_latitude) );
	is( $jupiter->radius_vector, '5.397121', 'Radius to Jupiter' );
	is( $jupiter->heliocentric_anomaly, '156.236900', 'Heliocentric anomaly for Jupiter' );
	is( $jupiter->heliocentric_latitude, '1.076044', 'Heliocentric latitude for Jupiter' );

	can_ok( $earth, qw(distance_to) );
	is( $earth->distance_to( $jupiter ), '5.603', 'Distance from earth to jupiter' );
	};

done_testing();
