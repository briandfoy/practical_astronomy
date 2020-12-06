use utf8;
use strict;
use open qw(:std :utf8);
use File::FindLib qw(lib);

use Test::More 1;

use PracticalAstronomy::Date;
use PracticalAstronomy::PlanetsData;

my $class;
BEGIN {
	subtest sanity => sub {
		$class = 'PracticalAstronomy::Util';
		use_ok( $class );
		} or BAIL_OUT();
	}

subtest jupiter_19881122 => sub {
	# Third Edition page 110
	my $data_file = 'data/planetary_data_1990.json';
	my $name = 'Jupiter';

	my $date = PracticalAstronomy::Date->new( 1988, 11, 22 );
	isa_ok( $date, 'PracticalAstronomy::Date' );

	my $earth = PracticalAstronomy::PlanetsData
		->new_from_file( $data_file )
		->data_for( 'Earth' )
		->clone_with_date( $date );
	isa_ok( $earth, 'PracticalAstronomy::Planet' );

	my $jupiter = PracticalAstronomy::PlanetsData
		->new_from_file( $data_file )
		->data_for( $name )
		->clone_with_date( $date );
	isa_ok( $jupiter, 'PracticalAstronomy::Planet' );

	is( $jupiter->epoch->elapsed_to( $date ),      '-404',        "Elasped days is correct" );
	is( $jupiter->orbital_period,                   '11.863075',  "Jupiter's orbital period is right" );
	is( $jupiter->Np,                               '326.433532', "Jupiter's Np is right" );
	is( $jupiter->heliocentric_longitude,            '60.851087', "Jupiter's heliocentric longitude is right" );
	is( $jupiter->true_anomaly,                      '46.680340', "Jupiter's true anomaly is right" );
	is( $jupiter->heliocentric_longitude_projected,  '60.858366', "Jupiter's protected heliocentric longitude" );
	is( $jupiter->radius,                             '5.023250', "Jupiter's radius is right" );
	# book says 5.396170, p. 127
	is( $jupiter->radius_projected,                   '5.022679', "Jupiter's projected radius is right" );
	is( $jupiter->heliocentric_latitude,             '-0.829193', "Jupiter's heliocentric latitude is right" );

	my $ε = ecliptic_obliquity( $date );
	my $λ = geocentric_ecliptic_longitude( $earth, $jupiter );
	my $β = geocentric_ecliptic_latitude( $earth, $jupiter );

	# Book says 166.310510
	is( $λ, '166.310512', "Jupiter's ecliptic longitude is right" );
	# Book says 1.036466
	is( $β, '1.036465', "Jupiter's ecliptic latitude is right" );

	my $α = right_ascension( $ε, $λ, $β );
	my $δ = declination( $ε, $λ, $β );
	is_deeply( decimal_to_dms($α), [qw(11 11 14)], "Jupiter's right ascension is right" );

	# book says 6 21 25
	is_deeply( decimal_to_dms($δ), [qw( 6 21 24)], "Jupiter's declination is right" );
	};

done_testing();
