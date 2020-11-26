package PracticalAstronomy::Date;
use v5.26;
use utf8;
use experimental qw(signatures);

use Carp     qw(croak);
use Exporter qw(import);

our @EXPORT = qw( to_julian elapsed_days );

=head1 NAME

PracticalAstronomy::Date - an object to represent a date

=head1 SYNOPSIS

The object interface:

	use PracticalAstronomy::Date;

	my $start = PracticalAstronomy::Date->new(
		2010, 1, 0, 0  # year, month, day, hour24
		);

	my $elapsed = $start->elapsed_to( $y, $m, $d, $h );
	my $julian  = $start->julian;
	my $mjd     = $start->modified_julian;

The functional interface:

	use PracticalAstronomy::Date;
	my $start = to_julian( $y, $m, $d, $h );
	my $later = to_julian( $y1, $m1, $d1, $h1 );
	my $elapsed = elapsed_days( $later, $start );

=head1 DESCRIPTION

This represents dates from UTC for astronomical computations.

=head2 Functions for Julian dates

=over 4

=item * to_julian( YEAR, MONTH, $DAY [, HOUR24 ] )

Returns the Julian date for the given year, month, day, and hour.

See Fourth Edition, page 9

=cut

sub to_julian ( $y, $m, $d, $hour = 0 ) {
	croak( "Bad month <$m>"   ) unless $m    =~ /\A((1[012])|0?[1-9])\z/n;
	croak( "Bad day <$d>"     ) unless $d    =~ /\A(3[01]|[012]?[0-9])\z/n;
	croak( "Bad hour <$hour>" ) unless $hour =~ /\A(2[0-3]|[01]?[0-9])\z/n;
	$d += $hour / 24;

	my( $y_, $m_ ) = do {
		if( $m < 3 ) { ( $y - 1, $m + 12 ) }
		else         { ( $y,     $m      ) }
		};

	my $B = do {
		if( sprintf( '%04d%02d%02d', $y, $m, $d ) ge "15821015" ) {
			my $A = int( $y_/100 );
			2 - $A + int( $A/4 );
			}
		else { 0 }
		};

	my $C = do {
		if( $y_ < 0 ) { int(365.25 * $y_ - 0.75) }
		else          { int(365.25 * $y_       ) }
		};

	my $D = int( 30.6001 * ( $m_ +1 ) );

	# warn( "B: $B C: $C D: $D d: $d\n" );

	my $JD = $B + $C + $D + $d + 1_720_994.5;
	}

=item * elapsed_days( JULIAN1, JULIAN2 )

See page 9.

=cut

sub elapsed_days ( $j1, $j2 ) { $j2 - $j1 }

=back

=head2 Methods

=over 4

=item * new( YEAR, MONTH, DAY [, HOUR24 = 0 ] )

Return a new date object based on the year, month, day, and hour
(in UT).

The hour is in 24 hour time and can be a fraction.

=cut

sub new ( $class, $y, $m, $d, $h = 0 ) {
	my $self = bless {
		year  => $y,
		month => $m,
		day   => $d,
		hour  => $h
		}, $class;

	$self->{julian} = to_julian( $y, $m, $d, $h );

	$self;
	}

=item * new_from_now( YEAR, MONTH, DAY [, HOUR24 = 0 ] )

Return a new date object using the current time.

=cut

sub new_from_now ( $class ) {
	my( $y, $m, $d, $h ) = (gmtime)[5, 4, 3, 2];
	$class->new( 1900+$y, 1+$m, $d, $h );
	}

=item * ecliptic_olbiquity_epoch

Returns a date object for the epoch for the olbiquity of the ecliptic.

=cut

sub ecliptic_olbiquity_epoch ( $class ) {
	state $obj = __PACKAGE__->new( 2000, 1, 1, 12 );
	$obj;
	}

=head2 Accessors

=over 4

=item * year

=item * month

=item * day

=item * hour

=cut

sub year  { $_[0]->{'year'} }
sub month { $_[0]->{'month'} }
sub day   { $_[0]->{'day'} }
sub hour  { $_[0]->{'hour'} }

=item * yyyymmddhh

Format the date as a single string.

=cut

sub yyyymmddhh { sprintf '%4d%02d%02d%02d', map { $_[0]->$_() } qw(year month day hour) }

=item * julian

Returns the Julian date.

=cut

sub julian { $_[0]->{'julian'} }

=item * modified_julian( [DATE] )

Returns the modified Julian date ( epoch time at 0h on 17 November 1858 ).

Optionally, pass this a ::Date object to use a different offset. For
example, the ecliptic of the obliquity uses 2000 Jan 1.5.

=cut

sub modified_julian ( $self, $offset = __PACKAGE__->new(1858,11,17) ) {
	$self->julian - $offset->julian;
	}

=item * elapsed_to

Returns the number of julian days between the two dates.

=cut

sub elapsed_to ( $self, $date ) { $date->julian - $self->julian }

=back


1;
