use utf8;
use v5.26;
use File::FindLib qw(lib);

package PracticalAstronomy::Planet;

use Carp qw(croak carp);
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

=item * clone_with_date( $self, $y, $m, $d, $h = 0 )

Copy the object and add an observation date.

=cut

use Storable qw(dclone);
sub clone_with_date ( $self, $y, $m, $d, $h = 0 ) {
	my $hash = dclone $self;

	bless $hash, ref $self;
	delete $hash->{calc_date};
	delete $hash->{computed};

	$hash->set_date( $y, $m, $d, $h = 0 );

	$hash->{calc_date}{elapsed} = $hash->epoch->elapsed_to( $y, $m, $d, $h );

	$hash;
	}

=item * set_date( $y, $m, $d, $h = 0 )

Set the date for the observation. The computed values use this date.

=item * date_is_set()

Returns true if the object has had the date set, and false otherwise.

=cut

sub set_date ( $self, $y, $m, $d, $h = 0 ) {
	$self->{calc_date}{year}  = $y;
	$self->{calc_date}{month} = $m;
	$self->{calc_date}{date}  = $d;
	$self->{calc_date}{hour}  = $h;

	$self->{calc_date}{elapsed} = $self->epoch->elapsed_to( $y, $m, $d, $h );
	}

sub date_is_set ( $self ) {
	return exists $self->{calc_date}{year}
	}

=item * distance_to( PLANET )

Returns the distance from the invocant planet to the specified one.

=cut

sub distance_to ( $self, $planet ) {
	my $R = $self->radius_vector;
	my $r = $planet->radius_vector;

	my $L = $self->heliocentric_anomaly;
	my $l = $planet->heliocentric_anomaly;

	my $ψ = $planet->heliocentric_latitude;

	my $ρ2 =
		  $R ** 2
		+ $r ** 2
		- ( 2 * $R * $r * cos_d( $l - $L ) * cos_d( $ψ ) );

	round( sqrt( $ρ2 ), 3 );
	}

=item * days_since_epoch

Returns the number of days since the epoch for this data.

=cut

sub days_since_epoch ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}
	$self->{calc_date}{elapsed};
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


=item * Np

Returns

=cut

sub Np ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}

	my $Np = ( 360 / days_in_year ) * ( $self->days_since_epoch / $self->orbital_period );
	while(1) { last if $Np >=   0; $Np += 360 }
	while(1) { last if $Np <= 360; $Np -= 360 }

	round( shift_into_360( $Np ) )
	}

=item * mean_anomaly

Returns the mean anomaly, M, in degrees

=cut

sub mean_anomaly ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}

	my $M =
		$self->Np
		+ $self->long_at_epoch
		- $self->long_at_perihelion;

	round( $M );
	}

=item * true_anomaly

Returns the true anomaly, ν, in degrees

=cut

sub true_anomaly ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}

	my $M = $self->mean_anomaly;
	my $ν = $M + (360/π) * $self->eccentricity * sin_d($M);
	round( shift_into_360( $ν ) );
	}

=item * eccentric_anomaly

Uses Kepler's equation to determine the anomaly and is more precise
than the true anomaly. Returns that value in degrees.

1. Firstguess,putE=E0 =M.
2. Find the value of δ = E −esinE −M.
3. If† |δ|≤ε gotostep6.
If |δ | > ε proceed with step 4.
ε is the required accuracy (= 10−6 radians).
4. Find ∆E = δ/(1−ecosE).
5. TakenewvalueE1 =E−∆E. Gotostep2.
6. The present value of E is the solution, correct to within ε of the true value.

p.  107

=cut

use Math::Trig qw(rad2deg deg2rad);
sub eccentric_anomaly ( $self, $precision = 1.e-6 ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	# Everything is in radians in this equation
	my $M = deg2rad( $self->mean_anomaly );
	my $e = $self->eccentricity;
	my( $E0, $E ) = ( $M ) x 2; # Step 1

	my sub δ  () { $E - $e * sin( $E ) - $M };
	my sub ΔE () { δ() / ( 1 - $e * cos( $E ) ) };

	my $steps;
	LOOP: {
		$steps++;
		if( abs(δ) <= $precision ) { return round6( rad2deg( $E ) ) }
		else                       { $E = $E - ΔE; redo   }
		}

	return;
	}


=item * heliocentric_anomaly

Returns the heliocentric anomaly, l

=cut

sub heliocentric_anomaly ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		shift_into_360( $self->true_anomaly  + $self->long_at_perihelion )
		);
	}

=item * radius_vector

Returns the radius vector, r

=cut

sub radius_vector ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		( $self->semi_major_axis * ( 1 - $self->eccentricity ** 2 ) )
			/ # /
		( 1 +  $self->eccentricity * cos_d( $self->true_anomaly ) )
		);
	}

=item * heliocentric_latitude

Returns the heliocentric latitude, ψ

=cut

sub heliocentric_latitude ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		arcsin_d(
			sin_d( $self->heliocentric_anomaly - $self->long_of_ascending_node )
			* sin_d( $self->orbital_inclination )
			)
		);
	}

=cut

1;
