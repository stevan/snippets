package Snippet::Element;
use Moose;
use Moose::Util::TypeConstraints;

# this is where is all happens
# some of it ain't pretty either
# but it gives us a pretty front
# end, which right now is all I 
# care about (sorry jrockway)

use Carp qw(croak);

# NOTE:
# There is no reason why we cant
# use another XML parser here either
# they would simple need to reimplement
# about 80% of this class, but it is
# possible. (think: Drivers)
# - SL

use XML::LibXML;
use HTML::Selector::XPath;
use MooseX::Types::Path::Class qw(File);

use namespace::clean -except => 'meta';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# NOTE:
# this should likely be injected
# via Bread::Board I think, but 
# we really only need it very 
# occasionally, so I dunno.
# - SL
my $PARSER = XML::LibXML->new;
$PARSER->no_network(1);
$PARSER->keep_blanks(0); # << on the fly whitespace "compression"

class_type 'XML::LibXML::Node';
class_type 'XML::LibXML::NodeList';
class_type 'XML::LibXML::Document';

coerce 'XML::LibXML::Document'
    => from Str => via { $PARSER->parse_string($_) },
    => from File,  via { $PARSER->parse_file($_->stringify) };

# I am coerce-able
coerce 'Snippet::Element'
    => from Str => via { Snippet::Element->new(body => $_) },
    => from File,  via { Snippet::Element->new(body => $_) };

has 'parent' => (
    is        => 'ro',
    isa       => 'Snippet::Element',
    predicate => 'has_parent'
);

has '_body' => (
    init_arg => 'body',
    is       => 'rw',
    isa      => 'XML::LibXML::Document | XML::LibXML::Node | XML::LibXML::NodeList',
    coerce   => 1,
    required => 1,
);

sub clone {
    my $self = shift;

    (ref $self)->new( body => $self->_body->cloneNode(1) );
}

sub is_root { !(shift)->has_parent }

sub find {
    my ($self, $xpath) = @_;

    unless ( $xpath =~ m{(?: ^/ | ^id\( | [:\[@] )}x ) {
        $xpath = HTML::Selector::XPath::selector_to_xpath($xpath);
    }

    my $nodes = $self->_body->findnodes($xpath);

    return unless $nodes->size;

    return $self->_child_element($nodes->size == 1 ? $nodes->get_node(0) : $nodes);
}

sub children {
    my $self = shift;

    map { $self->_child_element($_) } $self->_child_nodes;
}

sub length {
    my $body = (shift)->_body;
    return 1 unless $body->isa('XML::LibXML::NodeList');
    return $body->size();
}

sub each {
    my ($self, $f) = @_;
    $f->($_) foreach $self->children;
    $self;
}

sub content {
    my ( $self, $replacement ) = @_;

    if ( ref $replacement ) {
        if ( blessed $replacement ) {
            if ( $replacement->isa("Snippet::Element") ) {
                $self->_replace_inner_node($replacement->_child_nodes);
            } else {
                $self->_replace_inner_node($replacement);
            }
        } else {
            croak "Content must be a string or an object";
        }
    } else {
        return $self->html($replacement);
    }
}

sub _prepare_new_children {
    my ( $self, @children ) = @_;

    map { $self->_prepare_new_child($_) } @children;
}

sub _prepare_new_child {
    my ( $self, $child ) = @_;

    if ( ref $child ) {
        if ( blessed $child ) {
            if ( $child->isa("Snippet::Element") ) {
                return $child->_child_nodes;
            } else {
                return $child;
            }
        } else {
            croak "Content must be a string or an object";
        }
    } else {
        return $PARSER->parse_string("<doc>$child</doc>")->documentElement->getChildnodes;
    }
}

sub append {
    my ( $self, @children ) = @_;

    $self->_body->addChild($_) for $self->_prepare_new_children(@children);
}

sub prepend {
    my ( $self, @children ) = @_;

    $self->_body->prepend($_) for reverse $self->_prepare_new_children(@children);
}

sub html {
    my ( $self, $child ) = @_;

    # NOTE:
    # I am not sure I like this <doc/> wrapper
    # but it does give us some more flexibility
    # in the API. It just feels wrong.
    # - SL
    my @nodes = $PARSER->parse_string("<doc>$child</doc>")->documentElement->getChildnodes;

    return $self->_replace_inner_node(@nodes);
}

sub text {
    my $self = shift;
    return $self->_replace_inner_node(
        XML::LibXML::Document->new->createTextNode(shift)
    );
}

sub attr {
    my ( $self, $name, @args ) = @_;

    my $body = $self->_body;
    (!$body->isa('XML::LibXML::NodeList'))
        || confess "Cannot call attr() on a node_list";

    $body->setAttribute($name, $args[0]) if @args;

    $body->getAttribute($name);
}

sub as_xml {
    shift->_body->toString;
}

sub render {
    my $self = shift;

    join( "", map { $_->toString } $self->_nodes );
}

# private 

sub _child_element {
    my ( $self, @args ) = @_;

    unshift @args, "body" if @args % 2;

    (ref $self)->new(
        parent => $self,
        @args,
    );
}

sub _node {
    my $self = shift;

    my $body = $self->_body;

    #warn "body: $body";

    if ($body->isa('XML::LibXML::Document')) {
        return $body->documentElement;
    } else {
        return $body;
    }
}

sub _nodes {
    my $self = shift;

    my $node = $self->_node;

    if ($node->isa('XML::LibXML::NodeList')) {
        return $node->get_nodelist;
    } else {
        return $node;
    }
}

sub _child_nodes {
    my $self = shift;

    my $body = $self->_body;

    if ( $body->isa('XML::LibXML::Document') ) {
        return $body->documentElement->getChildnodes;
    } else {
        return $self->_nodes;
    }
}

sub _replace_inner_node {
    my ($self, @new) = @_;

    my $old = $self->_body;

    if ($old->isa('XML::LibXML::NodeList')) {
        foreach my $node ($old->get_nodelist) {
            $node->removeChild($_) foreach $node->getChildnodes;
            $node->addChild($_->cloneNode(1)) for @new;
        }
    }
    else {
        $old->removeChild($_) foreach $old->getChildnodes;
        $old->addChild($_) for @new;
    }

    $self;
}

1;

__END__

