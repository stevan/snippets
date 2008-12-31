package Snippet::Element;
use Moose;
use Moose::Util::TypeConstraints;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use XML::LibXML;
use HTML::Selector::XPath;

my $PARSER = XML::LibXML->new;
$PARSER->no_network(1);
$PARSER->keep_blanks(0);

class_type 'XML::LibXML::Document';
class_type 'XML::LibXML::Node';
class_type 'XML::LibXML::NodeList';

coerce 'Snippet::Element'
    => from 'Str'
        => via { Snippet::Element->new(body => $_) };

subtype 'Snippet::Document' => as 'XML::LibXML::Document';

coerce 'Snippet::Document'
    => from 'Str'
        => via { $PARSER->parse_string($_) };

has 'parent' => (
    is        => 'ro',
    writer    => '_set_parent',
    isa       => 'Snippet::Element',
    weak_ref  => 1,
    predicate => 'has_parent'
);

has '_body' => (
    init_arg => 'body',
    is       => 'rw',
    isa      => 'Snippet::Document | XML::LibXML::Node | XML::LibXML::NodeList',
    coerce   => 1,
    required => 1,
);

sub is_root { !(shift)->has_parent }

sub find {
    my ($self, $selector) = @_;

    my $nodes = $self->_body->findnodes(
        HTML::Selector::XPath->new( $selector )->to_xpath
    );

    return unless $nodes->size;

    (blessed $self)->new(
        body   => ($nodes->size == 1 ? $nodes->get_node(0) : $nodes),
        parent => $self
    );
}

sub children {
    my $self = shift;
    map {
        (blessed $self)->new(
            body   => $_,
            parent => $self
        )
    } do {
        my $body = $self->_body;
        if ($body->isa('XML::LibXML::Document')) {
            $body->documentElement->getChildNodes
        }
        elsif ($body->isa('XML::LibXML::Node')) {
            $body
        }
        elsif ($body->isa('XML::LibXML::NodeList')) {
            $body->get_nodelist
        }
    }
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

sub html {
    my $self = shift;
    return $self->_replace_inner_node(
        $PARSER->parse_string(shift)->documentElement
    );
}

sub text {
    my $self = shift;
    return $self->_replace_inner_node(
        XML::LibXML::Document->new->createTextNode(shift)
    );
}

sub attr {
    my $body = (shift)->_body;
    (!$body->isa('XML::LibXML::NodeList'))
        || confess "Cannot call attr() on a node_list";
    my $name = shift;
    $body->setAttribute($name, $_[0]) if @_;
    $body->getAttribute($name);
}

sub render {
    my $body = (shift)->_body;
    if ($body->isa('XML::LibXML::Document')) {
        return $body->documentElement->toString;
    }
    elsif ($body->isa('XML::LibXML::Node')) {
        return $body->toString;
    }
    elsif ($body->isa('XML::LibXML::NodeList')) {
        return join "" => map { $_->toString } $body->get_nodelist;
    }
}

# private 

sub _replace_inner_node {
    my ($self, $new) = @_;

    my $old = $self->_body;

    if ($old->isa('XML::LibXML::NodeList')) {
        foreach my $node ($old->get_nodelist) {
            $node->removeChild($_) foreach $node->getChildnodes;
            $node->addChild($new->cloneNode(1));
        }
    }
    else {
        $old->removeChild($_) foreach $old->getChildnodes;
        $old->addChild($new);
    }

    $self;
}

no Moose::Util::TypeConstraints; no Moose; 1;

__END__

