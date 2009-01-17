package TestApp::Pages::Login;
use Moose;

extends 'Snippet::Page';

has 'message' => (
    traits   => [ 'Snippet::Meta::Attribute::Trait' ],
    selector => '.message',
    is       => 'ro',
    isa      => 'Snippet',   
    required => 1
);

has 'login_form' => (
    traits   => [ 'Snippet::Meta::Attribute::Trait' ],
    selector => '#login_form',    
    is       => 'ro',
    isa      => 'TestApp::Snippet::LoginForm',   
    required => 1,
    handles  => [qw[ is_authenticated ]]
);

sub RUN {
    my ($self, $request) = @_;
    if ($self->is_authenticated) {
        $self->login_form->visible(0);
        $self->message->html('<em>Thank You For Logging In</em>');
    }
}

1;