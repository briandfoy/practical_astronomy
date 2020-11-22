use Test::More 1;

use File::FindLib qw(lib);

my $planets;

subtest planets_data => sub {
	my $class     = 'PracticalAstronomy::PlanetsData';
	my $data_file = 'data/planetary_data_2010.json';
	use_ok( $class );
	ok( -e $data_file, "Data file <$file> exists" );
	$planets = $class->new_from_file( $data_file );
	};

my $class     = 'PracticalAstronomy::Planet';
my @methods   = qw(
	days_since_epoch
	orbital_period
	eccentricity
	long_at_perihelion
	long_at_epoch
	orbital_inclination
	long_of_ascending_node
	angular_diameter_1au
	visual_magnitude_1au
	mean_anomaly
	true_anomaly
	);

subtest load => sub {
	my $planet = $planets->data_for( 'mercury' );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );
	};

use Mojo::Util qw(dumper);
subtest methods => sub {
	my $planet = $planets->data_for( 'venus' );
	isa_ok( $planet, $class );
	can_ok( $planet, @methods );

	foreach my $method ( @methods ) {
		next unless $method eq 'days_since_epoch';
		ok( defined $planet->$method() );
		}

	is( $planet->name,                   'Venus',     'name for Venus'                   );
	is( $planet->orbital_period,         '0.615207',  'orbital_period (Tp) for Venus'    );
	is( $planet->eccentricity,           '0.006812',  'eccentricity for Venus'           );
	is( $planet->long_at_perihelion,     '131.54',    'long_at_perihelion for Venus'     );
	is( $planet->long_at_epoch,          '272.30044', 'long_at_epoch for Venus'          );
	is( $planet->orbital_inclination,    '3.3947',    'orbital_inclination for Venus'    );
	is( $planet->long_of_ascending_node, '76.769',    'long_of_ascending_node for Venus' );
	is( $planet->angular_diameter_1au,   '16.92',     'angular_diameter_1au for Venus'   );
	is( $planet->visual_magnitude_1au,   '-4.40',     'visual_magnitude_1au for Venus'   );
	};

done_testing();
