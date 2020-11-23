use utf8;
use open qw(:std :utf8);
use File::FindLib qw(lib);

use Test::More 1;

my $class;
BEGIN {
	$class = 'PracticalAstronomy::Util';
	subtest sanity => sub {
		use_ok( $class );
		ok( defined &{"$_"}, "\&$_ is defined" )
			for ( qw(sin_d cos_d arcsin_d arccos_d tan_d arctan_d ) );
		} or BAIL_OUT();
	}

subtest sine => sub {
	ok( defined &sin_d, "sin_d is defined"             );
	ok( sin_d(   0 ) < 1e-15, 'sin(0) is close to 0'   );
	is( sin_d(  90 ),  1,     'sin(90) is  1'          );
	ok( sin_d( 180 ) < 1e-15, 'sin(180) is close to 0' );
	is( sin_d( 270 ), -1,     'sin(270) is -1'         );
	};

subtest arcsine => sub {
	ok( defined &arcsin_d, "arcsin_d is defined"  );
	is( arcsin_d( 0 ),  0, 'arcsin_d( 0) is 0'    );
	is( arcsin_d( 1 ), 90, 'arcsin_d(90) is 1'    );
	};

subtest cosine => sub {
	ok( defined &cos_d,       "cos_d is defined"       );
	ok( cos_d(  90 ) < 1e-15, 'cos(0) is close to 0'   );
	is( cos_d(   0 ),  1,     'cos(90) is  1'          );
	ok( cos_d( 270 ) < 1e-15, 'cos(180) is close to 0' );
	is( cos_d( 180 ), -1,     'cos(270) is -1'         );
	};

subtest arccosine => sub {
	ok( defined &arccos_d, "arccos_d is defined"  );
	is( arccos_d( 1 ),  0, 'arccos_d( 0) is 1'    );
	is( arccos_d( 0 ), 90, 'arccos_d(90) is 0'    );
	};

subtest tangent => sub {
	ok( defined &tan_d, "tan_d is defined"  );

	};

subtest arctangent => sub {
	ok( defined &arctan_d, "arctan_d is defined"  );

	};

done_testing();
