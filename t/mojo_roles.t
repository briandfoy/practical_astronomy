#!perl

use Test2::V0;
use strict;
use warnings;

use File::FindLib qw(lib);

my $MojoFileClass;

subtest setup => sub {
	my @roles = map { "Mojo::File::Role::${_}JSON" } qw(Slurp Spurt);
	use Mojo::File;
	$MojoFileClass = Mojo::File->with_roles( @roles );
	isa_ok( $MojoFileClass, 'Mojo::File' );
	can_ok( $MojoFileClass, qw(slurp_json spurt_json) );
	};

subtest slurp => sub {
	my( $input_file ) = 'data/planetary_data_2010.json';
	ok( -e $input_file, "File <$input_file> exists" );
	my $file = $MojoFileClass->new( $input_file );
	isa_ok( $file, 'Mojo::File' );
	can_ok( $file, 'slurp_json' );
	my $json = $file->slurp_json;
	is( ref $json, ref {}, 'Input JSON is a hash reference' );
	};

subtest spurt => sub {
	my $output_file = 'spurt-test.json';
	unlink $output_file;
	ok( ! -e $output_file, "File <$output_file> does not exist yet" );

	my $data = { a => 1, b => 4, t => 3 };
	my $file = $MojoFileClass->new( $output_file );
	isa_ok( $file, 'Mojo::File' );
	can_ok( $file, 'slurp_json' );
	$file->spurt_json( $data );
	ok( -e $output_file, "File <$output_file> exists" );

	my $json = $file->slurp_json;
	is( ref $json, ref {}, 'Input JSON is a hash reference' );
	# Test2 does is_deeply with is
	is( $json, $data, 'Data structures match' );

	ok( unlink($output_file), "Unlinked test file <$output_file>" )
		or diag( "unlinking <$output_file>: $!" );
	};

done_testing();
