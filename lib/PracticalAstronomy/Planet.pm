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

	$hash->{calc_date}{year}  = $y;
	$hash->{calc_date}{month} = $m;
	$hash->{calc_date}{date}  = $d;
	$hash->{calc_date}{hour}  = $h;

	$hash->{calc_date}{elapsed} = $hash->epoch->elapsed_to( $y, $m, $d, $h );

	$hash;
	}


=item * days_since_epoch

Returns the number of days since the epoch for this data.

=cut

sub days_since_epoch ( $self ) {
	unless( exists $self->{calc_date} ) {
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


sub _shift_into_360 ( $n ) {
	while(1) { last if $n >=   0; $n += 360 }
	while(1) { last if $n <= 360; $n -= 360 }
	$n;
	}

=item * Np

Returns

=cut

sub Np ( $self ) {
	unless( exists $self->{calc_date} ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}

	my $Np = ( 360 / days_in_year ) * ( $self->days_since_epoch / $self->orbital_period );
	while(1) { last if $Np >=   0; $Np += 360 }
	while(1) { last if $Np <= 360; $Np -= 360 }

	_shift_into_360( $Np )
	}

=item * mean_anomaly

Returns the mean anomaly, M, in degrees

=cut

sub mean_anomaly ( $self ) {
	unless( exists $self->{calc_date} ) {
		carp "Date not set for planet observation. Use clone_with_date() first.";
		return;
		}

	my $M =
		$self->Np
		+ $self->long_at_epoch
		- $self->long_at_perihelion;

	$M;
	}

=item * true_anomaly

Returns the true anomaly, ν, in degrees

=cut

sub true_anomaly ( $self ) {
	unless( exists $self->{calc_date} ) {
		carp "Date not set for planet observation. Use clone_with_date() first";
		return;
		}

	my $M = $self->mean_anomaly;
	say STDERR "Mp $M";
	say STDERR "e ", $self->eccentricity;
	my $ν = $M + (360/π) * $self->eccentricity * sin_d($M);
	say STDERR "ν ", $ν;
	_shift_into_360( $ν );
	}

=item * heliocentric_anomaly

Returns the heliocentric anomaly, l

=cut

sub heliocentric_anomaly ( $self ) {
	_shift_into_360( $self->true_anomaly  + $self->long_at_perihelion )
	}

=item * radius_vector

Returns the radius vector, r

=cut

sub radius_vector ( $self ) {
	( $self->semi_major_axis * ( 1 - $self->eccentricity ** 2 ) )
		/ # /
	( 1 +  $self->eccentricity * cos_d( $self->true_anomaly ) )
	}

=item * heliocentric_latitude

Returns the heliocentric latitude, ψ

=cut

sub heliocentric_latitude ( $self ) {
	arcsin_d(
		sin_d( $self->heliocentric_anomaly - $self->long_of_ascending_node ) * sin_d( $self->inclination )
		);
	}

=cut

1;
