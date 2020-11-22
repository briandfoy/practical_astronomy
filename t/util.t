use utf8;
use open qw(:std :utf8);
use File::FindLib qw(lib);

use Test::More 1;

my $class;
BEGIN {
	my $class = 'PracticalAstronomy::Util';
	use_ok( $class );
	}

subtest constants => sub {
	ok( defined &π, 'π is a subroutine' );
	ok( defined π, 'π returns a defined value' );
	};

done_testing();
