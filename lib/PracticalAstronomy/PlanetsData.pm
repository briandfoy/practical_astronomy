package PracticalAstronomy::PlanetsData;
use v5.26;
use experimental qw(signatures);

use Mojo::File;
my $MojoFile = Mojo::File->with_roles(qw(
	Mojo::File::Role::SlurpJSON
	Mojo::File::Role::SpurtJSON
	));
use Mojo::Util qw(dumper);

sub new ( $class, $data ) { bless $data, $class }

sub new_from_file ( $class, $file ) {
	$class->new( $MojoFile->new( $file )->slurp_json );
	}

sub _meta ( $self ) { $self->{meta} }
sub _data ( $self ) { $self->{data} }

sub planet_name_key ( $self ) { 'P' }
sub names ( $self ) {
	state $k = $self->planet_name_key;
	map { $_->{$k} } $self->_data->@*;
	}

sub _data_for ( $self, $name ) {
	state $k = $self->planet_name_key;
	my( $planet ) = grep { fc($_->{$k}) eq fc($name) } $self->_data->@*;
	$planet;
	}

sub data_for ( $self, $name ) {
	state $k = $self->planet_name_key;

	my $planet = $self->_data_for( $name );
	return unless ref $planet;

	$planet->{date}   = $self->_meta->{epoch};
	$planet->{symbol} = $self->symbol_for( $name );

	$planet;
	}

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

1;
