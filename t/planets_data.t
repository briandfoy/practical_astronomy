use Test::More 1;

use File::FindLib qw(lib);

my $data_file;
my $class;

BEGIN {
$class = 'PracticalAstronomy::PlanetsData';
$data_file = 'data/planetary_data_2010.json';
subtest load => sub {
	use_ok( $class );
	ok( -e $data_file, "Data file <$file> exists" );
	};
}

subtest names => sub {
	my $method = 'names';
	can_ok( $class, $method );
	my $planets = $class->new_from_file( $data_file );
	isa_ok( $planets, $class );
	};

done_testing();
