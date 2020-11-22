use Pod::Coverage;

BEGIN {
package Pod::Coverage::Extractor;
use utf8;

sub command {
    my $self = shift;
    my ( $command, $text, $line_num ) = @_;
    if ( $command eq 'item' || $command =~ /^head(?:2|3|4)/ ) {

        # take a closer look
        my @pods = ( $text =~ /\s*([^\s\|,\/]+)/g );
        $self->{recent} = [];

        foreach my $pod (@pods) {
            print "Considering: '$pod'\n" if debug;

            # it's dressed up like a method cal
            $pod =~ /-E<\s*gt\s*>(.*)/ and $pod = $1;
            $pod =~ /->(.*)/           and $pod = $1;

            # it's used as a (bare) fully qualified name
            $pod =~ /\w+(?:::\w+)*::(\w+)/ and $pod = $1;

            # it's wrapped in a pod style B<>
            $pod =~ s/[A-Z]<//g;
            $pod =~ s/>//g;

            # has arguments, or a semicolon
            $pod =~ /(\w+)\s*[;\(]/ and $pod = $1;

            print "Adding: '$pod'\n" if debug;
            push @{ $self->{ $self->{nonwhitespace}
                    ? "recent"
                    : "identifiers" } }, do{ utf8::decode($pod); $pod };
        }
    }
}

}

use File::FindLib qw(lib);

use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
all_pod_coverage_ok();
