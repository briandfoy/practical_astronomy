#!perl
use utf8;
use v5.20;

package PracticalAstronomy::Util;

use experimental qw(signatures);

use Carp     qw(croak);
use Exporter qw(import);

our @EXPORT = qw(
	π days_in_year
	cos_d sin_d tan_d
	arcsin_d arccos_d arctan_d
	);

=encoding utf8

=head1 NAME

PracticalAstronomy::Util

=head1 SYNOPSIS

	use PracticalAstronomy::Util;

=head1 DESCRIPTION

=head2 Trig functions for degrees

=over 4

=item * cos_d( DEGREES )

Return the cosine, given the angle in degrees.

=item * sin_d( DEGREES )

Return the sine, given the angle in degrees.

=item * tan_d( DEGREES )

Return the tangent, given the angle in degrees

=item * arccos_d( COSINE )

Return the arccosine.

=item * arcsin_d( SINE )

Return the arcsine.

=item * arctan_d( TAN )

Return the arctangent.

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

=back

=cut

1;
