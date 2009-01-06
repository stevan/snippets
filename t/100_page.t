#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use FindBin;

use lib "$FindBin::Bin/lib";

BEGIN {
    use_ok('Snippet');
    use_ok('Snippet::Element');
    use_ok('Snippet::Page');
}

use TestApp::Snippet::LoginForm;
use TestApp::Pages::Login;

my $html_dir = Path::Class::Dir->new($FindBin::Bin, qw[ lib html ]);

sub make_login {
    return TestApp::Pages::Login->new(
        html => $html_dir->file(qw[ testapp pages login.html ]),
        snippets => {
            '.message'    => Snippet->new(html => '<strong>Please Login</strong>'),
            '#login_form' => TestApp::Snippet::LoginForm->new(
                html => $html_dir->file(qw[ testapp snippet loginform.html ])
             ),
        },
    );
}

{
    my $p = make_login;
    isa_ok($p, 'Snippet::Page');

    ok(!$p->is_authenticated, '... we are not authenticated');

    lives_ok {
        $p->process({});
    } '... process the page';

    ok(!$p->is_authenticated, '... we are not authenticated');

    is(
        $p->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><strong>Please Login</strong></div><div id="login_form"><form><label>Username</label><input type="text" name="username"/><label>Password</label><input type="text" name="password"/><hr/><input type="submit"/></form></div><div class="message"><strong>Please Login</strong></div></body></html>},
        '... got the right HTML'
    );
}

{
    my $p = make_login;
    isa_ok($p, 'Snippet::Page');

    lives_ok {
        $p->process({ username => 'foo', password => 'bar' });
    } '... process the page';

    ok($p->is_authenticated, '... we are now authenticated');

    is(
        $p->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><em>Thank You For Logging In</em></div><div id="login_form"><!-- login form goes here --></div><div class="message"><em>Thank You For Logging In</em></div></body></html>},
        '... got the right HTML'
    );
}

{
    my $p = make_login;
    isa_ok($p, 'Snippet::Page');

    lives_ok {
        $p->process({ username => 'bar', password => 'foo' });
    } '... process the page';

    ok(!$p->is_authenticated, '... we are no longer authenticated');

}
