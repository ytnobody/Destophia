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

Destophia - More micro sized Web-API Framework

=head1 SYNOPSIS

In your API Root Class ...

  package MyApp;
  use Destophia;
  use DBI;
  
  ### Load config and instantiate Destopia
  my $c = Destopia->new( config => +{
      db   => +{ ... },
      mail => +{ ... },
  } );

  ### Specify path-routing
  $c->router(
      qr'^/register$'   => 'MyApp::regiter';
      qr'^/user/(\d+)$' => 'MyApp::user',
      qr'^/$'           => 'MyApp::index',
  );
  
  sub new { bless +{ c => $c }, 'MyApp' }
  
  ### store db connection into container
  sub db {
      my $self = shift;
      my $db_conf = $self->c->config->{db};
      $self->c->entry( db => sub { DBI->connect( @{$db_conf->{connect_info}} } );
  }
  
  ### Controller logic
  sub index {
      my ($class, $self, $req) = @_;
      return +{ hello => 'world'};
  }
  
  sub user {
      my ($class, $self, $req, $match) = @_;
      my $userid = $match->{capture}[0];
      my $sth = $self->db->prepare('SELECT * FROM user WHERE id = ?');
      $sth->execute( $userid );
      my $user = $sth->fetchrow_arrayref;
      return +{ user  => $user };
  }
  
  sub register {
      my ($class, $self, $req) = @_;
      my $name = $req->param('name');
      my $age = $req->param('age');
      my $sth = $self->db->prepare('INSERT INTO user (`name`,`age`) VALUES (?, ?)');
      $sth->execute($name, $age);
      return +{ done => 1 };
  }
  1;

And, your app.psgi ...

  use MyApp;
  MyApp->app;

Finally, you can plackup it.

=head1 DESCRIPTION

Destophia is micro sized Web-API Framework.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
