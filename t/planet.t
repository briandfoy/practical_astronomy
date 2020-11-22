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
	};

done_testing();
