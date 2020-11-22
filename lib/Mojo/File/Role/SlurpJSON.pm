package Mojo::File::Role::SlurpJSON;
use Mojo::Base -role;
use Mojo::JSON qw(decode_json);
sub slurp_json { decode_json( $_[0]->slurp ) }
1;

=encoding utf8

=head1 NAME

Mojo::File::Role::SlurpJSON - a role to combine two steps

=head1 SYNOPSIS

	my $MojoFile = Mojo::File->with( 'Mojo::File::Role::SpurtJSON' );
	my $json = $MojoFile->new( $file )->slurp_json;

=head1 DESCRIPTION

=over 4

=item * slurp_json( $file )

C<slurp> the file and decode it as JSON, returning the Perl data
structure.

=back

=cut
