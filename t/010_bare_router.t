#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Path::Router;
use Plack::Test;

{
    package Foo;
    use Moose;
    use Bread::Board;
    extends 'OX::Application';

    has '+router_class' => (default => 'Path::Router');

    sub configure_router {
        my $self = shift;
        my ($s, $router) = @_;

        $router->add_route('/' => (
            target => sub { [200, [], ['root']] }
        ));
        $router->add_route('/:number' => (
            validations => {
                number => 'Int',
            },
            target => sub {
                my $env = shift;
                my ($num) = @{ $env->{'plack.router.match.args'} };
                return [200, [], ["got $num"]];
            }
        ));
    }
}

my $app = Foo->new;
my $router = $app->resolve(service => 'Router');

path_ok($router, $_, '... ' . $_ . ' is a valid path')
    for qw[
        /
        /10
        /246
    ];

routes_ok($router, {
    ''    => {},
    '10'  => { number => 10  },
    '246' => { number => 246 },
},
"... our routes are valid");

test_psgi
    app => $app->to_app,
    client => sub {
        my $cb = shift;
        {
            my $req = HTTP::Request->new(GET => "http://localhost/");
            my $res = $cb->($req);
            is($res->content, 'root', "right content for /");
        }
        {
            my $req = HTTP::Request->new(GET => "http://localhost/10");
            my $res = $cb->($req);
            is($res->content, 'got 10', "right content for /10");
        }
        {
            my $req = HTTP::Request->new(GET => "http://localhost/246");
            my $res = $cb->($req);
            is($res->content, 'got 246', "right content for /246");
        }
    };

done_testing;
