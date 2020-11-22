use Test::More 1;

use File::FindLib qw(lib);

BEGIN {
my $class = 'PracticalAstronomy::Util';
subtest load => sub {
	use_ok( $class );
	};
}

subtest basic_date => sub {
	my $jd = to_julian( 1985, 2, 17, 6 );
	is( $jd, "2446113.75", "Feb 17, 1985 at 6am is 2446113.75" );
	};

subtest zero_date => sub {
	my $jd = to_julian( -4712, 1, 1, 12 );
	is( $jd, "0", "Jan 1, 4713BC at noon is 0" );
	};

# Third edition epoch
subtest epoch_date => sub {
	my $jd = to_julian( 1990, 1, 0 );
	is( $jd, "2447891.5", "Jan 1, 1990 at midnight is 2447891.5" );
	};

# Fourth edition epoch
subtest '2009_date' => sub {
	my $jd = to_julian( 2009, 6, 19, 18 );
	is( $jd, "2455002.25", "Jun 19, 2009 at 6pm is 2455002.25" );
	};

subtest elapsed_days => sub {
	my $j1 = to_julian( 1985, 2, 17 );
	my $j2 = to_julian( 1990, 1, 0 );
	is( $j1, "2446113.5", "Feb 17, 1985 at midnight is 2446113.5" );
	is( $j2, "2447891.5", "Jan 1, 1990 at midnight is 2447891.5" );
	is( elapsed_days( $j2, $j1 ), -1778 );
	};

subtest bad_month => sub {
	my $rc = eval { to_julian( 2009, 13, 19, 18 ) };
	my $at = $@;
	ok( ! defined $rc, 'eval returns undef' );
	ok( defined $at, "There's something in \$@" );
	like( $at, qr/bad month/i );
	};

subtest bad_day => sub {
	my $rc = eval { to_julian( 2009, 6, 39, 23 ) };
	my $at = $@;
	ok( ! defined $rc, 'eval returns undef' );
	ok( defined $at, "There's something in \$@" );
	like( $at, qr/bad day/i );
	};

subtest bad_hour => sub {
	my $rc = eval { to_julian( 2009, 6, 19, 29 ) };
	my $at = $@;
	ok( ! defined $rc, 'eval returns undef' );
	ok( defined $at, "There's something in \$@" );
	like( $at, qr/bad hour/i );
	};

done_testing();
