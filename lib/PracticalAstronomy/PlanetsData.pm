use utf8;

package PracticalAstronomy::PlanetsData;
use v5.26;

use experimental qw(signatures);

use Mojo::File;
my $MojoFile = Mojo::File->with_roles(qw(
	Mojo::File::Role::SlurpJSON
	Mojo::File::Role::SpurtJSON
	));
use Mojo::Util qw(dumper);

use PracticalAstronomy::Planet;

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=item * new( HASH )

=item * new_from_file( FILE )

=cut

sub new ( $class, $data ) { bless $data, $class }

sub new_from_file ( $class, $file ) {
	$class->new( $MojoFile->new( $file )->slurp_json );
	}

sub _meta ( $self ) { $self->{meta} }
sub _data ( $self ) { $self->{data} }

sub _planet_name_key              { 'P'  }
sub _orbital_period_key           { 'Tp' }
sub _eccentricity_key             { 'e'  }
sub _inclination_key              { 'i'  }
sub _longitude_epoch_key          { 'ɛ'  }
sub _longitude_perihelion_key     { 'ω'  }
sub _longitude_ascending_node_key { 'Ω'  }
sub _semi_major_axis_key          { 'a'  }
sub _visual_magnitude_key         { 'V0' }
sub _angular_diameter_key         { 'Θ0' }
sub _epoch_key                    { 'epoch' }
sub _symbol_key                   { 'symbol' }

=item * names

Returns the names of the planets as a list.

=cut

sub names ( $self ) {
	state $k = $self->_planet_name_key;
	map { $_->{$k} } $self->_data->@*;
	}

sub _data_for ( $self, $name ) {
	state $k = $self->_planet_name_key;
	my( $planet ) = grep { fc($_->{$k}) eq fc($name) } $self->_data->@*;
	$planet;
	}

=item * data_for( PLANET_NAME )

Returns a L<PracticalAstronomy::Planet> object for the named planet.
The name is case insensitive.

=cut

sub data_for ( $self, $name ) {
	state $k = $self->_planet_name_key;

	my $planet = $self->_data_for( $name );
	return unless ref $planet;

	$planet->{ $self->_epoch_key  } = $self->_meta->{epoch};
	$planet->{ $self->_symbol_key } = $self->symbol_for( $name );

	PracticalAstronomy::Planet->new( $planet );
	}

=item * symbol_for( PLANET_NAME )

Returns the astrological symbol for the named planet. The name is
case insensitive.

=cut

sub symbol_for ( $self, $name ) {
	state %symbols = qw(
		mercury ☿
		venus   ♀
		earth   ♁
		mars    ♂
		saturn  ♄
		jupiter ♃
		uranus  ♅
		neptune ♆
		pluto   ♇
		);

	$symbols{ lc $name };
	}

=back

=cut
1;
