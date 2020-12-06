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


subtest mercury_19881122 => sub {
	# Third Edition page 108
	# Data corrected to match the outputs in the book
	my $data_file = 'data/corrected-1990.json';
	my $name = 'Mercury';

	my $date = PracticalAstronomy::Date->new( 1988, 11, 22 );
	isa_ok( $date, 'PracticalAstronomy::Date' );

	my $mercury = PracticalAstronomy::PlanetsData
		->new_from_file( $data_file )
		->data_for( $name )
		->clone_with_date( $date );
	isa_ok( $mercury, 'PracticalAstronomy::Planet' );

	is( $mercury->days_since_epoch,  '-404', "Days since epoch is correct" );

	is( $mercury->orbital_period,                     '0.240850', "Mercury's orbital period is right" );
	is( $mercury->Np,                               '146.682450', "Mercury's Np is right" );


	is( $mercury->mean_anomaly,                     '130.132370', "Mercury's M is right" );
	is( $mercury->heliocentric_longitude,           '225.447818', "Mercury's heliocentric longitude is right" );
	is( $mercury->true_anomaly,                     '148.147988', "Mercury's true anomaly is right" );

	is( $mercury->long_of_ascending_node,            '48.212740', "Mercury's ascending node is right" );

	# book says 225.468423, might be an arctan
	is( $mercury->heliocentric_longitude_projected, '225.468422', "Mercury's projected heliocentric longitude is right" );

	is( $mercury->orbital_inclination,                '7.004540', "Mercury's orbital inclination is right" );

	is( $mercury->radius,                             '0.449190', "Mercury's radius is right" );
	is( $mercury->radius_projected,                   '0.449182', "Mercury's radius projected is right" );
	is( $mercury->heliocentric_latitude,              '0.337048', "Mercury's heliocentric latitude is right" );
	};

done_testing();
