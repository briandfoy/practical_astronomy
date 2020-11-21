#!perl
use utf8;
use v5.20;

package PracticalAstronomy::Util;

use experimental qw(signatures);

use Carp     qw(croak);
use Exporter qw(import);


our @EXPORT = qw( to_julian elapsed_days π );

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
	croak( "Bad month <$m>" ) unless $m =~ /\A(?:1[012])|[1-9]\z/;
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

=head2 Physical constants

=over 4

=item * π

=cut

sub π () { 3.1415927 }

=cut

1;
