package Destophia;
use strict;
use warnings;
our $VERSION = '0.01';

use JSON::XS;
use Destophia::Router;
use Context::Micro;
use Plack::Request;

sub json {
    my $self = shift;
    $self->entry(json => sub { JSON::XS->new->utf8 });
}

sub router {
    my ($self, %route) = @_;
    $self->entry(router => sub { Destophia::Router->new(%route) });
}

sub app {
    my $self = shift;
    return sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        my $action = $self->router->match($req->path_info);
        return [404, [], ['Not Found']] unless $action;
        my ($class, $method) = @{$action}{'class','method'};
        my $res = $class->$method($self, $req, $action);
        [ 200, ['Content-Type' => 'application/json'], [$self->json->encode($res)] ];	
    };
}

sub bootstrap {
    my $self = shift;
    for my $action ( $self->router->actions ) {
        my ($subclass) = $action =~ /^(.+)::.+$/;
        try_to_load($subclass);
    }
}

sub try_to_load {
    my $mod = shift;
    (my $file = $mod.".pm") =~ s/::/\//g;
    require $file unless $INC{$file};
}

1;
__END__

=head1 NAME

Destophia - 

=head1 SYNOPSIS

  use Destophia;

=head1 DESCRIPTION

Destophia is

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
