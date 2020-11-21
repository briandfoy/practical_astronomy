package Mojo::File::Role::SlurpJSON;
use Mojo::Base -role;
use Mojo::JSON qw(decode_json);
sub slurp_json { decode_json( $_[0]->slurp ) }
1;
