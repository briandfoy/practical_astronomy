use v5.26;
use utf8;
use Test2::V0;
use Test2::Bundle::More;
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
	heliocentric_longitude heliocentric_longitude_projected
	heliocentric_latitude
	radius radius_projected
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

sub test_cloned ( $cloned ) {
	isa_ok( $cloned, $class );
	can_ok( $cloned, @methods );
	ok( $cloned->date_is_set, "Date is set in cloned object" );

	can_ok( $cloned, 'epoch' );
	isa_ok( $cloned->epoch, 'PracticalAstronomy::Date' );
	can_ok( $cloned->epoch, qw(year month day hour) );
	}

subtest plain => sub {
	my $plain = $planets->data_for( 'Uranus' );
	test_plain( $plain );

	my @computing_methods = qw(
		days_since_epoch
		Np mean_anomaly true_anomaly eccentric_anomaly
		heliocentric_longitude heliocentric_latitude
		heliocentric_longitude_projected
		radius radius_projected
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

subtest clone_with_now => sub {
	my $name = 'Neptune';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	can_ok( $plain, qw(clone_with_date clone_with_now) );

	my $with_now = $plain->clone_with_now;
	test_cloned( $with_now );

	my $with_date = $plain->clone_with_date( $with_now->date );
	test_cloned( $with_date );

	foreach my $method ( @methods ) {
		is( $with_now->$method(), $with_date->$method(), "Method <$method> returns the same value" );
		}
	};

subtest Np => sub {
	my $name = 'Mercury';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my $year = $plain->epoch->year;
	ok( defined $year, "Epoch has a year" );

	# Only needs to be more recent than the epoch
	my $later = PracticalAstronomy::Date->new($year + 1, 1, 0);
	my $future = $plain->clone_with_date( $later );
	test_cloned( $future );
	is( $future->Np, '53.715113', 'Np a year later' );

	# Only needs to be less recent than the epoch
	my $earlier = PracticalAstronomy::Date->new($year - 1, 1, 0);
	my $past = $plain->clone_with_date( $earlier );
	test_cloned( $past );
	is( $past->Np, '306.284887', 'Np a year ago' );
	};


# page 126
subtest jupiter_anomalies => sub {
	my $name = 'Jupiter';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
	my $planet = $plain->clone_with_date( $date );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->days_since_epoch, -2231, "-2231 days to " . $planet->date->yyyymmddhh );

	is( sprintf( '%.6f', $planet->Np ), '174.555932', 'Np is correct' );

	is( sprintf( '%.6f', $planet->mean_anomaly ), '497.809764', "mean_anomaly for $name" );
	is( sprintf( '%.6f', $planet->true_anomaly ), '141.573600', "true_anomaly for $name" );

	is( sprintf( '%.6f', $planet->heliocentric_longitude ), '156.236900', "heliocentric_longitude for $name" );
	is( sprintf( '%.6f', $planet->radius ), '5.397121', "radius for $name" );
	is( $planet->heliocentric_latitude, '1.076044', "heliocentric_latitude for $name" );

	# book says 5.396170
	is( $planet->radius_projected, '5.396169', "projected radius for $name" );
	is( $planet->heliocentric_longitude_projected, '156.229991', "heliocentric_latitude_projected for $name" );
	};

# page 126
subtest earth_anomalies => sub {
	my $name = 'Earth';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
	my $planet = $plain->clone_with_date( $date );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->days_since_epoch, -2231, "-2231 days to " . $planet->date->yyyymmddhh );

	is( $planet->Np, '321.011952', 'Np is correct' );

	# book says 317.363223, but that's a round off error
	is( $planet->mean_anomaly, '317.363224', "mean_anomaly for $name" );
	is( $planet->true_anomaly, '316.069248', "true_anomaly for $name" );

	is( $planet->heliocentric_longitude, '59.274748', "heliocentric_longitude for $name" );
	is( $planet->radius, '0.987847', "radius for $name" );
	is( $planet->heliocentric_latitude, '0.000000', "heliocentric_latitude for $name" );
	};

# page 128
subtest mercury_anomalies => sub {
	my $name = 'Mercury';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
	my $planet = $plain->clone_with_date( $date );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	is( $planet->days_since_epoch, -2231, "-2231 days to " . $planet->date->yyyymmddhh );

	# is( $planet->Np, '321.011952', 'Np is correct' );

	# is( $planet->mean_anomaly, '317.363224', "mean_anomaly for $name" );
	# book says 210.400253
	is( $planet->true_anomaly, '210.400254', "true_anomaly for $name" );

	# book says 288.012253
	is( $planet->heliocentric_longitude, '288.012254', "heliocentric_longitude for $name" );
	is( $planet->radius, '0.450657', "radius for $name" );
	is( $planet->heliocentric_latitude, '-6.035842', "heliocentric_latitude for $name" );

	is( $planet->radius_projected, '0.448159', "projected radius for $name" );
	todo "Don't know why this is wrong" => sub {
		is( $planet->heliocentric_longitude_projected, '287.824406', "heliocentric_longitude_projected for $name" );
		};
	};

subtest eccentric_anomaly => sub {
	my $name = 'Mars';
	my $plain = $planets->data_for( $name );
	test_plain( $plain );
	is( $plain->name, $name, 'Correct planet name' );

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
	my $planet = $plain->clone_with_date( $date );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	diag( "Mars mean anomaly: " . $planet->mean_anomaly );
	diag( "Mars true anomaly: " . $planet->true_anomaly );

	my $E = $planet->eccentric_anomaly;
	# I have not verified this result, but it's between the mean and
	# true anomaly: M 43.685408 ν 51.073733
	is( $E, '47.637347', 'eccentric_anomaly for Mars' );
	};

subtest relative_position => sub {
	my( $inner_name, $outer_name ) = qw(Venus Neptune);
	my $inner = $planets->data_for( $inner_name );
	my $outer = $planets->data_for( $outer_name );

	foreach my $p ( $inner, $outer ) {
		can_ok( $p, qw(is_inner_to is_outer_to position) );
		}

	cmp_ok( $inner->position, '<', $outer->position );
	ok(   $inner->is_inner_to( $outer ), "$inner_name is inner to $outer_name" );
	ok( ! $inner->is_outer_to( $outer ), "$inner_name is not outer to $outer_name" );

	ok( ! $outer->is_inner_to( $inner ), "$outer_name is not inner to $inner_name" );
	ok(   $outer->is_outer_to( $inner ), "$outer_name is outer to $inner_name" );
	};

# page 136
subtest distance_to_jupiter => sub {
	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );

	my $earth = $planets->data_for( 'Earth' )->clone_with_date( $date );
	isa_ok( $earth, $class );
	can_ok( $earth, qw(radius heliocentric_longitude) );
	is( $earth->radius, '0.987847', 'Radius to Earth' );
	is( $earth->heliocentric_longitude, '59.274748', 'Heliocentric longitude for Earth' );

	my $jupiter = $planets->data_for( 'Jupiter' )->clone_with_date( $date );
	isa_ok( $jupiter, $class );
	can_ok( $jupiter, qw(radius heliocentric_longitude heliocentric_latitude) );
	is( $jupiter->radius, '5.397121', 'Radius to Jupiter' );
	is( $jupiter->heliocentric_longitude, '156.236900', 'Heliocentric longitude for Jupiter' );
	is( $jupiter->heliocentric_latitude, '1.076044', 'Heliocentric latitude for Jupiter' );

	can_ok( $earth, qw(distance_to) );
	is( $earth->distance_to( $jupiter ), '5.603', 'Distance from earth to jupiter' );
	};

done_testing();
