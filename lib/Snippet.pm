package Snippet;
use Moose;

use Snippet::Element;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'html' => (
    is       => 'rw',
    isa      => 'Snippet::Element',   
    coerce   => 1,
    required => 1,
    handles  => {
        'find' => 'find'
    }
);

has 'visible' => (
    is      => 'rw',
    isa     => 'Bool',   
    default => sub { 1 },
);

sub RUN {} # override me ...

sub process {
    my ($self, $request) = @_;
    $self->RUN($request);
    $self;
}

sub render {
    my $self = shift;
    return unless $self->visible;
    $self->html->render;
}

no Moose; 1;

__END__

=pod

=head1 NAME

Snippet - A Moosey solution to this problem

=head1 SYNOPSIS

  use Snippet;

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

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
