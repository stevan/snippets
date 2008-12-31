#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Snippet::Element');
}


my $e = Snippet::Element->new(
    body => q{
        <ul>
            <li>one</li>
            <li>two</li>
            <li>three</li>
        </ul>
    }
);
isa_ok($e, 'Snippet::Element');

is($e->length, 1, '... is a single element');

is($e->render, '<ul><li>one</li><li>two</li><li>three</li></ul>', '... got the right HTML');

my $e2 = $e->find('li');

is($e2->length, 3, '... is not a single element');

is($e2->render, '<li>one</li><li>two</li><li>three</li>', '... got the right HTML');

$e2->text('foo');

is($e2->render, '<li>foo</li><li>foo</li><li>foo</li>', '... got the right HTML');
is($e->render, '<ul><li>foo</li><li>foo</li><li>foo</li></ul>', '... got the right HTML');

$e2->html('<b>hello</b>');

is($e2->render, '<li><b>hello</b></li><li><b>hello</b></li><li><b>hello</b></li>', '... got the right HTML');
is($e->render, '<ul><li><b>hello</b></li><li><b>hello</b></li><li><b>hello</b></li></ul>', '... got the right HTML');


