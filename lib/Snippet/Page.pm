package Snippet::Page;
use Moose;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'html' => (
    is       => 'ro',
    isa      => 'Snippet::Element',   
    coerce   => 1,
    required => 1,
    handles  => {
        'find' => 'find'
    }
);

has '_snippets_map' => (
    is      => 'ro',
    isa     => 'HashRef[Snippet]',   
    lazy    => 1,
    default => sub {
        my $self = shift;
        return +{
            map  { $_->selector => $_->get_value($self)                  }
            grep { $_->does('Snippet::Meta::Attribute::Traits::Snippet') } 
            $self->meta->get_all_attributes
        }
    }
);

sub RUN {} # override me ...

sub process {
    my ($self, $request) = @_;
    foreach my $id (keys %{ $self->_snippets_map }) {
        $self->_snippets_map->{$id}->process($request)
    }
    $self->RUN($request);    
    $self;
}

sub render {
    my ($self) = @_;
    # for each snippet ...
    foreach my $id (keys %{ $self->_snippets_map }) {
        # with the output of 
        # the snippet render()
        # method
        if (my $out = $self->_snippets_map->{$id}->render) {
            # find the ID in our document
            # ... and then replace the html
            $self->find($id)->html($out);
        }
    }
    $self->html->render;
}

no Moose; 1;

__END__

=pod

=head1 NAME

Snippet::Page - A Moosey solution to this problem

=head1 SYNOPSIS

  use Snippet::Page;

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
