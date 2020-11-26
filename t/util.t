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

subtest obliquity => sub {
	my $date_class = 'PracticalAstronomy::Date';
	use_ok( $date_class );
	my $date = $date_class->new( 2009, 7, 6 );
	isa_ok( $date, $date_class );
	is( $date->julian, '2455018.5', 'Julian date is correct' );

	my $epoch = $date->ecliptic_olbiquity_epoch;
	is(
		$epoch->julian, '2451545',
		'ecliptic olbiquity epoch is correct'
		);

	is(
		$date->modified_julian( $epoch ),
		'3473.5',
		'Modified Julian date is correct'
		);

	ok( defined &ecliptic_obliquity, 'ecliptic_obliquity is a subroutine' );
	is( ecliptic_obliquity($date), '23.438055', 'ecliptic_obliquity returns expected value' );
	};

# page 39
subtest decimal_to_dms => sub {
	ok( defined &decimal_to_dms, 'decimal_to_dms is a subroutine' );
	my $result = decimal_to_dms('182.524167');
	ok( defined $result, "decimal_to_dms returns a defined value" );
	is( ref $result, ref [], 'decimal_to_dms returns an array ref' );
	is_deeply( $result, [ qw(182 31 27) ], 'decimal_to_dms returns an array ref' );
	};

# page 39
subtest dms_to_decimal => sub {
	ok( defined &dms_to_decimal, 'dms_to_decimal is a subroutine' );
	my $result = dms_to_decimal( qw(182 31 27) );
	ok( defined $result, "dms_to_decimal returns a defined value" );
	ok( ! ref $result, "dms_to_decimal does not return a reference" );

	is( $result, '182.524167', 'dms_to_decimal returns 182.524167' );

	};

done_testing();
