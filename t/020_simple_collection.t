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
            <li></li>
        </ul>
    }
);
isa_ok($e, 'Snippet::Element');

my $row_template = $e->find('li');

$e->clear->append(map { $row_template->clone->text($_) } 1 .. 5);

is($e->render, '<ul><li>1</li><li>2</li><li>3</li><li>4</li><li>5</li></ul>', '... got the right HTML');




