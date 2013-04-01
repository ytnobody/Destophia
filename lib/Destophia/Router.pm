package Destophia::Router;
use strict;
use warnings;

sub new {
    my $class = shift;
    return bless [ @_ ], $class;
}

sub actions {
    my $self = shift;
    my %route = (@{$self});
    return values %route;
}

sub match {
    my ($self, $str) = @_;
    my $i = 0;
    my ($regex, $class, $method);
    my @matched;
    while ( $regex = $self->[$i * 2] ) {
        if ( @matched = $str =~ $regex ) {
            ($class, $method) = $self->[$i * 2 + 1] =~ /^(.+)::(.+?)$/;
            return +{ 
                class => $class,
                method => $method, 
                capture => [ @matched ], 
            };
        }
        $i++;
    }
}

1;
