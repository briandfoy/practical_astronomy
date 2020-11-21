package Mojo::File::Role::SpurtJSON;
use Mojo::Base -role;
use Mojo::JSON qw(encode_json);
sub spurt_json { $_[0]->spurt( encode_json($_[1]) ) }
1;
