use utf8;
use strict;
use open qw(:std :utf8);
use File::FindLib qw(lib);

use Test::More 1;

use PracticalAstronomy::Date;
use PracticalAstronomy::PlanetsData;
use PracticalAstronomy::Util;

my $class;
BEGIN {
	subtest sanity => sub {
		$class = 'PracticalAstronomy::Util';
		use_ok( $class );
		} or BAIL_OUT();
	}

subtest obliquity => sub {
	# page 52 - expected value is 23 26 17
	my $date = PracticalAstronomy::Date->new( 2009, 7, 6 );
	isa_ok( $date, 'PracticalAstronomy::Date' );

	ok( defined &ecliptic_obliquity, 'ecliptic_obliquity is defined' );
	ok( defined &decimal_to_dms,     'decimal_to_dms is defined' );

	my $ε = ecliptic_obliquity( $date );
	is( $ε, '23.43805531', 'decimal value is correct' );

	is_deeply( decimal_to_dms($ε), [ qw(23 26 17) ], 'dms values are correct' );
	};

subtest right_ascension => sub {
	# page 53
	ok( defined &right_ascension, 'right_ascension is defined' );
	my $date = PracticalAstronomy::Date->new( 2009, 7, 6 );
	my $ε = ecliptic_obliquity( $date );
	my $λ = '139.686111';
	my $β = '4.875278';

	my $α = right_ascension( $ε, $λ, $β );
	is( $α, '9.581478', 'α is correct' );
	is_deeply( decimal_to_dms($α), [ qw(9 34 53) ], 'dms values are correct' );
	};

subtest declination => sub {
	ok( defined &right_ascension, 'right_ascension is defined' );
	my $date = PracticalAstronomy::Date->new( 2009, 7, 6 );
	my $ε = ecliptic_obliquity( $date );
	my $λ = '139.686111';
	my $β = '4.875278';

	my $δ = declination( $ε, $λ, $β );
	is( $δ, '19.535003', 'δ is correct' );
	is_deeply( decimal_to_dms($δ), [ qw(19 32 6) ], 'dms values are correct' );
	};

subtest mercury_20031122 => sub {
	my $data_file = 'data/planetary_data_2010.json';
	my $name = 'Mercury';

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
	isa_ok( $date, 'PracticalAstronomy::Date' );

	my $mercury = PracticalAstronomy::PlanetsData
		->new_from_file( $data_file )
		->data_for( $name )
		->clone_with_date( $date );
	isa_ok( $mercury, 'PracticalAstronomy::Planet' );

	# book says xxx.xxx253
	is( $mercury->heliocentric_longitude,           '288.012254', "Mercury's heliocentric longitude is right" );
	is( $mercury->true_anomaly,                     '210.400254', "Mercury's true anomaly is right" );
	is( $mercury->heliocentric_longitude_projected, '287.824406', "Mercury's projected heliocentric longitude is right" );
	is( $mercury->long_of_ascending_node,            '48.449',    "Mercury's ascending node is right" );
	is( $mercury->radius,                             '0.450657', "Mercury's radius is right" );
	is( $mercury->radius_projected,                   '0.448159', "Mercury's radius projected is right" );
	is( $mercury->heliocentric_latitude,             '-6.035842', "Mercury's heliocentric latitude is right" );
	};

subtest jupiter_20031122 => sub {
	my $data_file = 'data/planetary_data_2010.json';
	my $name = 'Jupiter';

	my $date = PracticalAstronomy::Date->new( 2003, 11, 22 );
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

	is( $jupiter->heliocentric_longitude,           '156.236900', "Jupiter's heliocentric longitude is right" );
	is( $jupiter->true_anomaly,                     '141.573600', "Jupiter's true anomaly is right" );
	is( $jupiter->heliocentric_longitude_projected, '156.229991', "Jupiter's protected heliocentric longitude" );
	is( $jupiter->radius,                             '5.397121', "Jupiter's radius is right" );
	# book says 5.396170, p. 127
	is( $jupiter->radius_projected,                   '5.396169', "Jupiter's projected radius is right" );
	is( $jupiter->heliocentric_latitude,              '1.076044', "Jupiter's heliocentric latitude is right" );

	my $ε = ecliptic_obliquity( $date );
	diag( "This far: $ε" );
	my $λ = geocentric_ecliptic_longitude( $earth, $jupiter );
	diag( "This far: $λ" );
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

	ok( defined &sky_position, 'sky_position is defined' );
	my @sky_position = sky_position( $earth, $jupiter );
	is( scalar @sky_position, 2, 'sky_position returns two items' );

	is( $sky_position[0], $α, 'sky_position returns correct right ascention' );
	is( $sky_position[1], $δ, 'sky_position returns correct declination' );
	};

done_testing();
