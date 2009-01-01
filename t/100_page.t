#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

BEGIN {
    use_ok('Snippet');
    use_ok('Snippet::Element');      
    use_ok('Snippet::Page');        
}

{
    package TestApp::Snippet::LoginForm;
    use Moose;
    
    extends 'Snippet';
    
    has 'is_authenticated' => (
        is      => 'rw',
        isa     => 'Bool',   
        default => sub { 0 },
    );
    
    sub authenticate { 
        my ($self, $username, $password) = @_;
        $self->is_authenticated(1);
    }
    
    sub RUN {
        my ($self, $request) = @_;
        if ($request->{username} && $request->{password}) {
            $self->authenticate($request->{username}, $request->{password});
        }
    }
}

{
    package TestApp::Pages::Login;
    use Moose;
    
    extends 'Snippet::Page';
    
    sub is_authenticated {
        (shift)->snippets->{'#login_form'}->is_authenticated
    }
    
    sub RUN {
        my ($self, $request) = @_;
        if ($self->is_authenticated) {
            # redirect to logged in area ...
        }
        # otherwise present the form ...
    }
}

my $p = TestApp::Pages::Login->new(
    html => q{
        <html>
            <head>
                <title>Please Login</title>
            </head>
            <body>
                <div class="message"></div>
                <div id="login_form">
                    <!-- login form goes here -->
                </div>
                <div class="message"></div>                
            </body>
        </html>
    },
    snippets => {
        '.message'    => Snippet->new(html => '<strong>Please Login</strong>'),
        '#login_form' => TestApp::Snippet::LoginForm->new(
            html => q{
                <form>
                    <label>Username</label>
                    <input type="text" name="username" />
                    <label>Password</label>
                    <input type="text" name="password" />
                    <hr/>
                    <input type="submit" />
                </form>
            }
         ),
    },
);
isa_ok($p, 'Snippet::Page');

ok(!$p->is_authenticated, '... we are not authenticated');

$p->process({});

ok(!$p->is_authenticated, '... we are not authenticated');

is(
    $p->render, 
    q{<html><head><title>Please Login</title></head><body><div class="message"><strong>Please Login</strong></div><div id="login_form"><form><label>Username</label><input type="text" name="username"/><label>Password</label><input type="text" name="password"/><hr/><input type="submit"/></form></div><div class="message"><strong>Please Login</strong></div></body></html>},
    '... got the right HTML'
);

$p->process({ username => 'foo', password => 'bar' });

ok($p->is_authenticated, '... we are now authenticated');



