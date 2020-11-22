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

=item * names

Returns the names of the planets as a list.

=cut

sub _planet_name_key ( $self ) { 'P' }
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

	$planet->{epoch}  = $self->_meta->{epoch};
	$planet->{symbol} = $self->symbol_for( $name );

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
