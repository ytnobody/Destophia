package Destophia::Router;
use strict;
use warnings;

sub new {
    my $class = shift;
    return bless [ @_ ], $class;
}

sub match {
    my ($self, $str) = @_;
    my $i = 0;
    my $regex;
    my @matched;
    while ( $regex = $self->[$i * 2] ) {
        if ( @matched = $str =~ $regex ) {
            return +{ 
                matched => $self->[$i * 2 + 1], 
                capture => [ @matched ], 
            };
        }
        $i++;
    }
}

1;
