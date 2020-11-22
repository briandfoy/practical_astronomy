use utf8;
use v5.26;
use File::FindLib qw(lib);

package PracticalAstronomy::Planet;

use PracticalAstronomy::Util;
use experimental qw(signatures);

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * new( HASH )

Create a new planet object, although you probably want to go
through L<PracticalAstronomy::PlanetsData>.

The hash keys are:

	P  - Planet
	Tp - Period (tropical years)
	ɛ  - Longitude at epoch (degrees)
	ω  - Longitude of the perihelion (degrees)
	e  - Eccentricity of the orbit
	a  - Semi-major axis of the orbit
	i  - Inclination of the orbit (degrees)
	Ω  - Longitude of the ascending node (degrees)
	Θ0 - Angular diameter at 1 AU
	V0 - visual magnitude at 1 AU
	epoch - Gregorian epoch date, YYYY-MM-DD
	symbol - astrological symbol for the planet

=cut

sub new { bless $_[1], $_[0] }

=item * days_since_epoch

Returns the number of days since the epoch for this data.

=cut

sub days_since_epoch ( $self, $date=undef ) {
	unless( defined $date ) {
		my( $y, $m, $d ) = (gmtime)[5,4,3];
		$y += 1900;
		$m += 1;
		$date = sprintf '%4d-%02d-%02d', $y, $m, $d;
		}

	to_julian( split /-/, $date )
		- to_julian( split /-/, $self->epoch );
	}

=item * epoch

The epoch for the data, in YYYY-MM-DD

=item * orbital_period

Returns the orbital period in tropical years.

=item * eccentricity

Returns the eccentricity of the orbit.

=item * long_at_perihelion

Returns the longitude at perihelion, in degrees.

=item * long_at_epoch

Returns the longitude at the epoch, in degrees.

=item * orbital_inclination

Returns the orbital inclination, in degrees

=item * long_of_ascending_node

Returns the longitude if the ascending node, in degrees

=item * angular_diameter_1au

Returns the angular diameter at 1 AU, in degrees

=item * visual_magnitude_1au

Returns the visual magnitude at 1 AU.

=item * symbol

Returns the astrological symbol for the planet.

=cut

sub orbital_period         { $_[0]->{Tp} }
sub eccentricity           { $_[0]->{e}  }
sub long_at_perihelion     { $_[0]->{ω}  }
sub long_at_epoch          { $_[0]->{ɛ}  }
sub orbital_inclination    { $_[0]->{i}  }
sub long_of_ascending_node { $_[0]->{Ω}  }
sub angular_diameter_1au   { $_[0]->{Θ0} }
sub visual_magnitude_1au   { $_[0]->{V0} }

sub epoch                  { $_[0]->{epoch}  }
sub symbol                 { $_[0]->{symbol} }

=item * mean_anomaly

Returns the mean anomaly

=cut

sub mean_anomaly ( $self ) {
	my $M =
		( 360 / 365.242191 )
		* ( $self->days_since_epoch / $self->period )
		+ $self->eccentricity
		+ $self->long_at_perihelion
	}

=item * true_anomaly

Returns the true anomaly

=cut

sub true_anomaly ( $self ) {
	my $M = $self->mean_anomoly;
	$M + (360/π) * $self->eccentricity * sin($M);
	}

=back

=cut

1;
