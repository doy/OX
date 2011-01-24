#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Foo;
    use OX;

    config foo => 'bar';
    component baz => sub { bless {}, 'Bar' };
}

my $foo = Foo->new;
can_ok('Foo', $_) for qw(app_root app_router foo baz);
is($foo->app_root, '..', "correct app_root");
isa_ok($foo->app_router, 'OX::Router');
is($foo->foo, 'bar', "correct foo");
isa_ok($foo->baz, 'Bar');

done_testing;
