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
        <div>
        <div>one</div>
        <div>two</div>
        <div>three</div>                        
        </div>
    }
);
isa_ok($e, 'Snippet::Element');

is($e->length, 1, '... is a single element');

is($e->render, '<div><div>one</div><div>two</div><div>three</div></div>', '... got the right HTML');

my @children;
$e->each(sub { 
    my $el = shift;
    isa_ok($el, 'Snippet::Element');
    is($el->length, 1, '... is a single element');    
    push @children => $el 
});

is(scalar @children, 3, '... got three child elements');

is($children[0]->render, '<div>one</div>', '... got the right HTML');
is($children[1]->render, '<div>two</div>', '... got the right HTML');
is($children[2]->render, '<div>three</div>', '... got the right HTML');

lives_ok {
    $children[1]->text('2')
} '... replaced text okay';

is($children[1]->render, '<div>2</div>', '... got the right HTML');
is($e->render, '<div><div>one</div><div>2</div><div>three</div></div>', '... got the right HTML');


