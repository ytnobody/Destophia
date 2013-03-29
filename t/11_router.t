use strict;
use warnings;
use Test::More;
use Destophia::Router;

my $r = Destophia::Router->new(
    qr'^/geo/([0-9]+)/([0-9]+)' => 'Geo::index',
    qr'^/user/([0-9a-zA-Z_]+)'  => 'User::index',
    qr'^/([0-9]+)'              => 'Number::index',
    qr'^/'                      => 'Root::index',
);

isa_ok $r, 'Destophia::Router';
is_deeply $r->match('/'), +{ matched => 'Root::index', capture => [ 1 ] };
is_deeply $r->match('/12345'), +{ matched => 'Number::index', capture => [ 12345 ] };
is_deeply $r->match('/user/ytnobody1234'), +{ matched => 'User::index', capture => [ 'ytnobody1234' ] };
is_deeply $r->match('/geo/100/200'), +{ matched => 'Geo::index', capture => [ 100, 200 ] };
is_deeply $r->match('/fjkafjgsdk'), +{ matched => 'Root::index', capture => [ 1 ] };
is_deeply $r->match('geo/100/200'), undef;

done_testing;
