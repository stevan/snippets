#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN {
    use_ok('Snippet');
}

{
    package My::Greeting::Snippet;
    use Moose;
    
    extends 'Snippet';
    
    sub RUN {
        my ($self, $request) = @_;
        if (my $thing = $request->{greeting}) {
            $self->find('.thing')->text($thing);
        }
    }
}

my $s = My::Greeting::Snippet->new(
    html => q{<p>Hello <span class="thing">???</span></p>}
);
isa_ok($s, 'My::Greeting::Snippet');
isa_ok($s, 'Snippet');

lives_ok {
    $s->process({ greeting => 'World' });
} '... processed snippet okay';

is($s->render, '<p>Hello <span class="thing">World</span></p>', '... rendered correctly');







