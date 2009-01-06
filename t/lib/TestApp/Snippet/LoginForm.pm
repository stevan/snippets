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
    if ($request->param('username') && $request->param('password')) {
        $self->authenticate(
            $request->param('username'),
            $request->param('password')
        );
    }
}

1;