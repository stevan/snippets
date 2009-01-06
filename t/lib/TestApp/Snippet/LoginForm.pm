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
    $self->is_authenticated(
        $username eq 'foo' && $password eq 'bar' ? 1 : 0
    );
}

sub RUN {
    my ($self, $request) = @_;
    if ($request->{username} && $request->{password}) {
        $self->authenticate(
            $request->{username},
            $request->{password}
        );
    }
}

1;