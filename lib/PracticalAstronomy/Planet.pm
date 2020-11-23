use utf8;
use v5.26;
use File::FindLib qw(lib);

package PracticalAstronomy::Planet;

use PracticalAstronomy::JulianDate;
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

	to_julian( split /-/, $date ) - $self->epoch->julian;
	}

=item * name

Returns the name of the planet

=item * epoch

Returns the epoch for the data, in YYYY-MM-DD

=item * orbital_period

Returns the orbital period in tropical years, Tp

=item * eccentricity

Returns the eccentricity of the orbit, e

=item * long_at_perihelion

Returns the longitude at perihelion, in degrees, ω

=item * long_at_epoch

Returns the longitude at the epoch, in degrees, ε

=item * orbital_inclination

Returns the orbital inclination, in degrees, i

=item * long_of_ascending_node

Returns the longitude if the ascending node, in degrees, 􏰀Ω

=item * semi_major_axis

Returns the semi major axis, a

=item * angular_diameter_1au

Returns the angular diameter at 1 AU, in degrees, Θ0

=item * visual_magnitude_1au

Returns the visual magnitude at 1 AU, V0

=item * symbol

Returns the astrological symbol for the planet.

=cut

my $K = 'PracticalAstronomy::PlanetsData';
eval "require $K";

sub name                   { $_[0]->{ $K->_planet_name_key              } }
sub orbital_period         { $_[0]->{ $K->_orbital_period_key           } }
sub eccentricity           { $_[0]->{ $K->_eccentricity_key             } }
sub long_at_perihelion     { $_[0]->{ $K->_longitude_perihelion_key     } }
sub long_at_epoch          { $_[0]->{ $K->_longitude_epoch_key          } }
sub orbital_inclination    { $_[0]->{ $K->_inclination_key              } }
sub long_of_ascending_node { $_[0]->{ $K->_longitude_ascending_node_key } }
sub semi_major_axis        { $_[0]->{ $K->_semi_major_axis_key          } }
sub angular_diameter_1au   { $_[0]->{ $K->_angular_diameter_key         } }
sub visual_magnitude_1au   { $_[0]->{ $K->_visual_magnitude_key         } }

sub epoch                  { $_[0]->{ $K->_epoch_key                    } }
sub symbol                 { $_[0]->{ $K->_symbol_key                   } }

=item * mean_anomaly

Returns the mean anomaly, M

=cut

sub mean_anomaly ( $self ) {
	my $M =
		( 360 / days_in_year )
		* ( $self->days_since_epoch / $self->orbital_period )
		+ $self->eccentricity
		+ $self->long_at_perihelion
	}

=item * true_anomaly

Returns the true anomaly, ν

=cut

sub true_anomaly ( $self ) {
	my $M = $self->mean_anomaly;
	$M + (360/π) * $self->eccentricity * sin($M);
	}

=item * heliocentric_anomaly

Returns the heliocentric anomaly, l

=cut

sub heliocentric_anomaly ( $self ) {
	$self->true_anomaly + $self->long_at_perihelion
	}

=item * radius_vector

Returns the radius vector, r

=cut

sub radius_vector ( $self ) {
	( $self->semi_major_axis * ( 1 - $self->eccentricity ** 2 ) )
		/ # /
	( 1 +  $self->eccentricity * cos( $self->true_anomaly ) )
	}

=item * heliocentric_latitude

Returns the heliocentric latitude, ψ

=cut

sub heliocentric_latitude ( $self ) {
	arcsin(
		sin( $self->heliocentric_anomaly - $self->long_of_ascending_node ) * sin( $self->inclination )
		);
	}

=cut

1;
