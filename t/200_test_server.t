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
    use_ok('Snippet::Test::Server');
}

use TestApp::Snippet::LoginForm;
use TestApp::Pages::Login;

my $html_dir = Path::Class::Dir->new($FindBin::Bin, qw[ lib html ]);

sub make_login {
    return TestApp::Pages::Login->new(
        html       => $html_dir->file(qw[ testapp pages login.html ]),
        message    => Snippet->new(html => '<strong>Please Login</strong>'),
        login_form => TestApp::Snippet::LoginForm->new(
            html => $html_dir->file(qw[ testapp snippet loginform.html ])
         )
    );
}

my $server = Snippet::Test::Server->new(page_builder => \&make_login);
isa_ok($server, 'Snippet::Test::Server');

# $server->run;

