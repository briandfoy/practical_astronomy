use utf8;
use open qw(:std :utf8);
use File::FindLib qw(lib);

use Test::More 1;

my $class;
BEGIN {
	subtest sanity => sub {
		$class = 'PracticalAstronomy::Util';
		use_ok( $class );
		} or BAIL_OUT();
	}

subtest constants => sub {
	ok( defined &π, 'π is a subroutine' );
	ok( defined  π, 'π returns a defined value' );

	ok( defined &AU, 'AU is a subroutine' );
	ok( defined  AU, 'AU returns a defined value' );
	};

done_testing();
