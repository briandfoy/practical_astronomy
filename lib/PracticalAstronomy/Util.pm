#!perl
use utf8;
use v5.20;

package PracticalAstronomy::Util;

use experimental qw(signatures);

use Carp     qw(croak);
use Exporter qw(import);

our @EXPORT = qw(
	π AU
	days_in_year
	cos_d sin_d tan_d
	arcsin_d arccos_d arctan_d
	round round4 round6
	shift_into_360
	);

=encoding utf8

=head1 NAME

PracticalAstronomy::Util

=head1 SYNOPSIS

	use PracticalAstronomy::Util;

=head1 DESCRIPTION

=head2 Basic math things

=item * round( $n, $decimal_points = 6 )

Rounds the floating point number to the specified number of decimal
points, or 6 decimal places by default.

Many of the numbers and results from the book are six decimal places
but the computer can provide many more. Most of those extra digits are
probably insignificant though.

=item * round4( $n )

Rounds the floating point number to four decimal places.

=item * round6( $n )

Rounds the floating point number to six decimal places. This is the
same as the default behavior (currently), but is explicit about its
behavior.

=cut

sub round ( $n, $digits = 6 ) { sprintf '%.*2$f', $n, $digits }

sub round4 ( $n ) { round( $n, 4 ) }
sub round6 ( $n ) { round( $n, 6 ) }

=item * shift_into_360( $n )

Add or subtract 360 degrees until the number is within 0 to 360.

=cut

sub shift_into_360 ( $n ) {
	while(1) { last if $n >=   0; $n += 360 }
	while(1) { last if $n <= 360; $n -= 360 }
	$n;
	}

=back

=head2 Trig functions for degrees

=over 4

=item * cos_d( DEGREES )

Return the cosine, given the angle in degrees.

=item * sin_d( DEGREES )

Return the sine, given the angle in degrees.

=item * tan_d( DEGREES )

Return the tangent, given the angle in degrees

=item * arccos_d( COSINE )

Return the arccosine, in degrees.

=item * arcsin_d( SINE )

Return the arcsine, in degrees.

=item * arctan_d( TAN )

Return the arctangent, in degrees.

=cut

use Math::Trig qw(deg2rad rad2deg tan acos asin atan);

sub cos_d    ( $d ) {  cos( deg2rad($d) ) }
sub sin_d    ( $d ) {  sin( deg2rad($d) ) }
sub tan_d    ( $d ) {  tan( deg2rad($d) ) }

sub arccos_d ( $x ) { rad2deg( acos($x) ) }
sub arcsin_d ( $x ) { rad2deg( asin($x) ) }
sub arctan_d ( $x ) { rad2deg( atan($x) ) }

=back

=head2 Physical constants

=over 4

=item * π

=cut

sub π () { '3.1415927' }

=item * days_in_year

Returns the days in year, to six decimal places
=cut

sub days_in_year () { '365.242191' }

=item * AU

=cut

sub AU () { '149597870700' }

=back

=cut

1;
