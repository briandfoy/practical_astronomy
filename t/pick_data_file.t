use utf8;
use strict;
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

subtest functions => sub {
	ok( defined &pick_data_file, 'pick_data_file is a subroutine' );
	};

my @files = sort glob 'data/planet*.json';

subtest files => sub {
	ok( -e $_, "File <$_> exists" ) for @files;
	};

subtest functions => sub {
	my( $early, $middle, $later ) = qw(1988 2005 2012);
	is( pick_data_file( $early ), $files[0] );
	is( pick_data_file( $middle ), $files[1] );
	is( pick_data_file( $later ), $files[1] );
	};

done_testing();
