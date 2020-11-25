#!perl
use v5.20;
use utf8;

use experimental qw(signatures);

use Carp qw(carp);
use Mojo::UserAgent;
use Mojo::DOM;
use Mojo::JSON qw(encode_json);
use Mojo::Util qw(dumper);

my $ua = Mojo::UserAgent->new;

my $url = 'https://nssdc.gsfc.nasa.gov/planetary/factsheet/';

my $ua = Mojo::UserAgent->new;

my $dom = get_page( $url );

my $rows_c = $dom
	->at( 'table' )
	->find( 'tr' );

my $planets = $rows_c->first
	->find( 'td[align=center]' )
	->map( 'all_text' )
	->map( sub { s/\A\h+|\h+\z//g; ucfirst(lc()) } )
	->to_array;

my %Planets = map {
	state $n = 1;
	$_ => {
		Name     => $_,
		Position => $n++,
		}
	} $planets->@*;

# To make up for the first column, which is the datum name
unshift @$planets, undef;

foreach my $row ( $rows_c->@[ 1 .. $rows_c->$#* - 1 ] ) {
	my $name = $row->at( 'td[align=left]' )->all_text;
	$name =~ s/(?:10|\/[ms])\K(\d+)/ $1 =~ tr{1234567890}{¹²³⁴⁵⁶⁷⁸⁹⁰}r /e;
	my $values = $row
		->find( 'td[align=center]' )
		->map( 'all_text' )
		->map( sub { s/,//r } )
		->each( sub ( $e, $n ) {
			$Planets{ $planets->[$n] }{ $name } = $e;
			} );
	}

my $data = {
	_meta => {
		source => $url,
		datetime => scalar localtime,
		},
	data  => \%Planets,
	};

say encode_json( $data );

sub get_page ( $url ) {
	state $rc = require Digest::MD5;
	my $file = Digest::MD5::md5_hex($url);
	unless( -e $file ) {
		$ua->get( $url )->result->save_to( $file );
		}

	my $data = do {
		if( -e $file ) {
			Mojo::File->new( $file )->slurp;
			}
		else {
			carp "Could not find <$file> for <$url>";
			'';
			}
		};

	Mojo::DOM->new( $data );
	}

