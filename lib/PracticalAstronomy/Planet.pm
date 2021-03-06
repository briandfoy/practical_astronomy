use utf8;
use v5.26;
use File::FindLib qw(lib);

package PracticalAstronomy::Planet;

use Carp qw(croak carp);
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

The basic object is the (mostly) stable data and the date on which
its based. To get any of the computed data (such as the radius),
you need to set the observation date. You can make a new object with
C<clone_with_date>, or set the date with C<set_data>. That allows you
to make several objects for the same planet but different dates.

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

=item * clone_with_date( YEAR, MONTH, DATE [, HOUR24] )

Copy the object and add an observation date.

	my $plain = PracticalAstronomy::PlanetsData
		->new($file)->data_for( 'Neptune' );

	my $neptune20101122 = $plain->clone_with_date( $y, $m, $d, $h );
	my $neptune20101123 = $plain->clone_with_date( $y, $m, $d, $h );

=cut

use Storable qw(dclone);
sub clone_with_date ( $self, $date ) {
	my $hash = dclone $self;

	bless $hash, ref $self;
	delete $hash->{calc_date};
	delete $hash->{computed};

	$hash->set_date( $date );

	$hash->{calc_date}{elapsed} = $hash->epoch->elapsed_to( $date );

	$hash;
	}

=item * clone_with_now()

Like C<clone_with_date>, but uses the current time.

=cut

sub clone_with_now ( $self ) {
	$self->clone_with_date( PracticalAstronomy::Date->new_from_now );
	}

=item * set_date( YEAR, MONTH, DATE [, HOUR24] )

Set the date for the observation. The computed values use this date.

=item * date_is_set()

Returns true if the object has had the date set, and false otherwise.

=item * date()

Return the list of the year, month, date, and hour.

=cut

sub set_date ( $self, $date ) {
	$self->{calc_date}{object}  = $date;

	$self->{calc_date}{elapsed} = $self->epoch->elapsed_to( $date );
	}

sub date_is_set ( $self ) {
	return exists $self->{calc_date}{object}
	}

sub date ( $self ) { $self->{calc_date}{object} }

=item * days_since_epoch()

Returns the number of days since the epoch for this data.

=cut

sub days_since_epoch ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}
	$self->{calc_date}{elapsed};
	}

=back

=head2 Methods that deal with other planets

=over 4

=item * distance_to( PLANET )

Returns the distance from the invocant planet to the specified one.

=cut

sub distance_to ( $self, $planet ) {
	my $R = $self->radius;
	my $r = $planet->radius;

	my $L = $self->heliocentric_longitude;

	my $l = $planet->heliocentric_longitude;
	my $ψ = $planet->heliocentric_latitude;

	my $ρ2 =
		  $R ** 2
		+ $r ** 2
		- ( 2 * $R * $r * cos_d( $l - $L ) * cos_d( $ψ ) );

	round( sqrt( $ρ2 ), 3 );
	}

BEGIN {
my %positions = map { state $n = 0; $n++; lc($_) => $n, $n => $_ } qw(
	Mercury Venus
	Earth
	Jupiter Saturn Uranus Neptune Pluto
	);

=item * position

Returns the index of the position in the list of planets (so, Earth
is 3).

=cut


sub position ( $self ) { $positions{ lc $self->name } }

=item * is_outer_to( PLANET )

=item * is_inner_to( PLANET )

Returns true if the orbit is outside the orbit of PLANET.

=cut

sub is_outer_to ( $self, $planet ) {
	return $self->position > $planet->position;
	}


sub is_inner_to ( $self, $planet ) {
	return $self->position < $planet->position;
	}
}

=back

=head2 Planet things

=over 4

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

Returns the progress along the orbit.

=cut

sub Np ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}

	my $Np = ( 360 / days_in_year ) * ( $self->days_since_epoch / $self->orbital_period );

	while(1) { last if $Np >=   0; $Np += 360 }
	while(1) { last if $Np < 360; $Np -= 360 }

	round6( shift_into_360( $Np ) );
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

=item * radius, r

Returns the radius vector magnitude, r, in AU

=cut

sub radius ( $self ) {
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

=item * heliocentric_longitude, l

Returns the heliocentric longitude, l, in degrees

=cut

sub heliocentric_longitude ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		shift_into_360( $self->true_anomaly  + $self->long_at_perihelion )
		);
	}

=item * heliocentric_latitude, ψ

Returns the heliocentric latitude, ψ, in degrees

=cut

sub heliocentric_latitude ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		arcsin_d(
			sin_d( $self->heliocentric_longitude - $self->long_of_ascending_node )
			* sin_d( $self->orbital_inclination )
			)
		);
	}

=item * heliocentric_longitude_projected, l'

Returns the heliocentric longitude projected onto the ecliptic, l',
in degrees.

=cut

sub heliocentric_longitude_projected ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}

	my $y = sin_d( $self->heliocentric_longitude - $self->long_of_ascending_node ) * cos_d( $self->orbital_inclination );
	my $x = cos_d( $self->heliocentric_longitude - $self->long_of_ascending_node );

	round(
		shift_into_360(
			arctan_d( $y, $x ) + $self->long_of_ascending_node
			)
		);
	}

=item * radius_projected

Returns the radius vector magnitude as projected onto the ecliptic, r'

=cut

sub radius_projected ( $self ) {
	unless( $self->date_is_set ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}
	round(
		$self->radius * cos_d( $self->heliocentric_latitude )
		);
	}


=cut

1;
