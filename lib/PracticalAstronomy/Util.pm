#!perl
use utf8;
use v5.20;

package PracticalAstronomy::Util;

use experimental qw(signatures);

use Carp     qw(croak);
use Exporter qw(import);

our @EXPORT = qw(
	to_julian elapsed_days π
	cos_d sin_d arcsin_d arccos_d
	);

=encoding utf8

=head1 NAME

PracticalAstronomy::Util

=head1 SYNOPSIS

	use PracticalAstronomy::Util;

=head1 DESCRIPTION

=head2 Functions for Julian dates

=over 4

=item * to_julian( YEAR, MONTH, $DAY [, HOUR24 ] )

See page 9.

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

=head2 Trig functions for degrees

=over 4

=item * cos_d

Return the cosine, given the angle in degrees.

=item * sin_d

Return the sine, given the angle in degrees.

=item * arccos_d

Return the arccosine, given the angle in degrees.

=item * arcsin_d

Return the arcsine, given the angle in degrees.

=cut

use Math::Trig qw(deg2rad rad2deg acos asin);

sub cos_d    ( $d ) {  cos( deg2rad($d) ) }
sub sin_d    ( $d ) {  sin( deg2rad($d) ) }

sub arccos_d ( $x ) { rad2deg( acos($x) ) }
sub arcsin_d ( $x ) { rad2deg( asin($x) ) }

=back

=head2 Physical constants

=over 4

=item * π

=cut

sub π () { '3.1415927' }

=back

=cut

1;
