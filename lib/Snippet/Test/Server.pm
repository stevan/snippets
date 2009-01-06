package Snippet::Test::Server;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use HTTP::Engine;

has 'page_builder' => (
    is       => 'ro',
    isa      => 'CodeRef',   
    required => 1,
);

has 'engine' => (
    is      => 'ro',
    isa     => 'HTTP::Engine',   
    lazy    => 1,
    default => sub {
        my $callback = (shift)->page_builder;
        HTTP::Engine->new(
             interface => {
                 module => 'ServerSimple',
                 args   => {
                     host => 'localhost',
                     port =>  5050,
                 },
                 request_handler => sub {
                     return HTTP::Engine::Response->new( 
                         body => $callback->()->process(@_)->render
                     );
                 }
             },
         )
    },
    handles => [qw[ run ]],
);


no Moose; 1;

__END__

=pod

=head1 NAME

Snippet::Test::Server - A Moosey solution to this problem

=head1 SYNOPSIS

  use Snippet::Test::Server;

=head1 DESCRIPTION

=head1 METHODS 

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
