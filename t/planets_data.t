use Test::More 1;

use File::FindLib qw(lib);

BEGIN {
my $class = 'PracticalAstronomy::PlanetsData';
subtest load => sub {
	use_ok( $class );
	};
}

done_testing();
