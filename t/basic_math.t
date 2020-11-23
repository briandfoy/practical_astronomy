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
			for ( qw( round round4 round6 shift_into_360 ) );
		} or BAIL_OUT();
	}

subtest round => sub {
	ok( defined &round, "round is defined" );
	is( round( 1.12345621 ), '1.123456', 'round(1.12345621) rounds down' );
	is( round( 1.12345678 ), '1.123457', 'round(1.12345678) rounds up'  );

	is( round( 1.12345621, 6 ), '1.123456', 'round(1.12345621, 6) rounds down' );
	is( round( 1.12345678, 6 ), '1.123457', 'round(1.12345678, 6) rounds up'  );

	is( round( 1.12341621, 4 ), '1.1234', 'round(1.12341621, 4) rounds down' );
	is( round( 1.12345678, 4 ), '1.1235', 'round(1.12345678, 4) rounds up'  );
	};

subtest round4 => sub {
	ok( defined &round4, "round4 is defined" );
	is( round4( 1.12341621 ), '1.1234', 'round4(1.12341621) rounds down' );
	is( round4( 1.12345678 ), '1.1235', 'round4(1.12345678) rounds up'  );
	};

subtest round6 => sub {
	ok( defined &round6, "round6 is defined" );
	is( round( 1.12345621 ), '1.123456', 'round6(1.12345621) rounds down' );
	is( round( 1.12345678 ), '1.123457', 'round6(1.12345678) rounds up'  );
	};

subtest shift_into_360 => sub {
	ok( defined &shift_into_360, "shift_into_360 is defined" );
	my @table = qw(
		 720 360
		   0   0
		 180 180
		  45  45
		-180 180

		 360.125   0.125
		-360.125 359.875
		);

	while ( @table ) {
		my( $input, $output ) = ( shift @table, shift @table );
		is( shift_into_360($input), $output, "shift_into_360($input)" );
		}
	};

done_testing();
