use v5.26;

use Test::More 1;

use File::FindLib qw(lib);

my $class;
BEGIN {
$class = 'PracticalAstronomy::Date';
subtest load => sub {
	use_ok( $class );
	} or BAIL_OUT();
}

subtest basic_date => sub {
	my $jd = to_julian( 1985, 2, 17, 6 );
	is( $jd, "2446113.75", "Feb 17, 1985 at 6am is 2446113.75" );
	};

subtest new_from_now => sub {
	my $now = $class->new_from_now;
	isa_ok( $now, $class );

	my( $year, $month, $day, $hour ) = (gmtime)[5,4,3,2];
	$year += 1900;
	$month += 1;

	my @methods = qw( year month day hour );
	can_ok( $now, @methods );

	is( $now->year,  $year,  "Returns the right year" );
	is( $now->month, $month, "Returns the right month" );
	is( $now->day,   $day,   "Returns the right day" );
	is( $now->hour,  $hour,  "Returns the right hour" );
	};

subtest basic_object => sub {
	my( $year, $month, $day, $hour ) = qw(1990 1 0 0);
	my $start = $class->new( $year, $month, $day, $hour );
	isa_ok( $start, $class );

	my @methods = qw( year month day hour julian );

	can_ok( $start, @methods );

	is( $start->year,  $year,  "Returns the right year" );
	is( $start->month, $month, "Returns the right month" );
	is( $start->day,   $day,   "Returns the right day" );
	is( $start->hour,  $hour,  "Returns the right hour" );
	is( $start->julian, "2447891.5", "Jan 1, 1990 at midnight is 2447891.5" );
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

subtest elapsed_days_1990 => sub {
	my $j1 = to_julian( 1985, 2, 17 );
	my $j2 = to_julian( 1990, 1, 0 );
	is( $j1, "2446113.5", "(function) Feb 17, 1985 at midnight is 2446113.5" );
	is( $j2, "2447891.5", "(function) Jan 1, 1990 at midnight is 2447891.5" );
	is( elapsed_days( $j2, $j1 ), -1778, "(function) -1778 days between the two" );

	my $start = $class->new( 1990, 1, 0 );
	isa_ok( $start, $class );
	can_ok( $start, 'julian', 'elapsed_to' );

	my $end = $class->new( 1985, 2, 17 );
	isa_ok( $end, $class );
	can_ok( $end, 'julian' );

	is( $start->julian, "2447891.5", "(object) Jan 0, 1990 at midnight is 2447891.5" );
	is( $start->modified_julian, "47891", "(object) Jan 0, 1990 at midnight is 47891 (modified julian)" );
	is( $start->elapsed_to( $end ), -1778, "(object) -1778 days between the 1990-01-00 and 1985-02-17" );

	is( $end->julian, "2446113.5", "(object) Feb 17, 1985 at midnight is 2446113.5" );
	is( $end->modified_julian, "46113", "(object) Feb 17, 1985 at midnight is 46113 (modified julian)" );
	is( $end->elapsed_to( $start ), 1778, "(object) 1778 days between 1985-02-17 and 1990-01-00" );
	};

subtest elapsed_days_2010 => sub {
	my $j1 = to_julian( 1985, 2, 17 );
	my $j2 = to_julian( 2010, 1, 0 );
	is( $j1, "2446113.5", "Feb 17, 1985 at midnight is 2446113.5" );
	is( $j2, "2455196.5", "Jan 1, 2010 at midnight is 2455196.5" );
	is( elapsed_days( $j2, $j1 ), -9083 );
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
