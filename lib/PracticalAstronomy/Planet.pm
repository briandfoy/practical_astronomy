use utf8;

package PracticalAstronomy::Planet;

use PracticalAstronomy::Util;

sub new ( $class, $data ) { bless $_[1], $_[0] }


sub days_since_epoch ( $self, $date ) {
	my( $year, $month, $day ) = $self->{epoch};
	my $j = to_julian( $year, $month, $day );
	}

sub orbital_period ( $self )  { $self->{Tp} }

sub eccentricity ( $self ) { $self->{} }

sub long_at_perihelion ( $self ) { $self->{ω} }

sub mean_anomoly ( $self ) {
	my $M =
		( 360 / 365.242191 )
		* ( $self->days_since_epoch / $self->period )
		+ $self->eccentricity
		+ $self->long_at_perihelion
	}

sub true_anomoly ( $self ) {
	my $M = $self->mean_anomoly;
	$M + (360/π) * $self->eccentricity * sin($M);
	}

1;
