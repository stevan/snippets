package TestApp::Pages::Login;
use Moose;

extends 'Snippet::Page';

# just a few little short cuts ...
sub message          { (shift)->snippets->{'.message'}       }    
sub login_form       { (shift)->snippets->{'#login_form'}    }
sub is_authenticated { (shift)->login_form->is_authenticated }

sub RUN {
    my ($self, $request) = @_;
    if ($self->is_authenticated) {
        $self->login_form->visible(0);
        $self->message->html('<em>Thank You For Logging In</em>');
    }
}

1;