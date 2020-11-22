use Test::More 1;

use File::FindLib qw(lib);

my $class = 'PracticalAstronomy::PlanetsData';
my $data_file = 'data/planetary_data_2010.json';

subtest load => sub {
	use_ok( $class );
	ok( -e $data_file, "Data file <$file> exists" );
	};

subtest names => sub {
	my $method = 'names';
	can_ok( $class, $method );
	my $planets = $class->new_from_file( $data_file );
	isa_ok( $planets, $class );

	my @names = $planets->$method();
	is( scalar @names, 8, 'There are eight planets' );
	};

subtest data_for => sub {
	my $method = 'data_for';
	my $planets = $class->new_from_file( $data_file );
	isa_ok( $planets, $class );
	can_ok( $planets, $method );

	my $earth = $planets->$method( 'earth' );
	isa_ok( $earth, ref {}, 'Planet data is a hash ref' );
	$earth = $planets->$method( 'Earth' );
	isa_ok( $earth, ref {}, 'Planet data is a hash ref' );
	$earth = $planets->$method( 'EARTH' );
	isa_ok( $earth, ref {}, 'Planet data is a hash ref' );

	my $no_planet = $planets->$method( 'Zylon' );
	ok( ! defined $no_planet, 'Non-existent planet returns undef' );
	};

done_testing();
