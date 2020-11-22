package Mojo::File::Role::SpurtJSON;
use Mojo::Base -role;
use Mojo::JSON qw(encode_json);
sub spurt_json { $_[0]->spurt( encode_json($_[1]) ) }
1;

=encoding utf8

=head1 NAME

Mojo::File::Role::SpurtJSON - a role to combine two steps

=head1 SYNOPSIS

	my $MojoFile = Mojo::File->with( 'Mojo::File::Role::SpurtJSON' );
	$MojoFile->new( $file )->spurt_json( { a => 5 } );

=head1 DESCRIPTION

=over 4

=item * spurt_json( $data_structure )

Turn C<$data_structure> into JSON and C<spurt> it to the file.

=back

=cut
