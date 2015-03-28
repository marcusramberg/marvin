package Marvin::App;

use Mojo::Base 'Mojolicious';
use Mojo::Loader 'load_class';
use Carp();
use IO::Prompt;

use Marvin::Bus;

has adapters => sub { [] };
has password => sub { prompt('password: ', -e => '*'); };
has bus      => sub { Marvin::Bus->new() };

sub notify { shift->bus->notify(@_); }

sub start {
  my $self     = shift;
  my $config   = $self->config;
  my $adapters = $config->{adapters};
  Carp::croak 'adapters must be a list of hashes'
    unless $adapters && ref $adapters eq 'ARRAY';
  for my $adapter (@$adapters) {
    my $class = 'Marvin::Adapter::' . $adapter->{type};
    if (my $e = load_class($class)) {
      die ref $e ? "Exception: $e" : "$class not found!";
    }
    my $adapter = $class->new(config => $adapter);

    $adapter->register($self);
    push @{$self->adapters}, $adapter;
  }
  $self->SUPER::start(@_);
}

sub public {
  my ($self, $route, $cb) = @_;
  my $r = Mojolicious::Routes::Pattern->new($route);
  $self->bus->on(
    'public',
    sub {
      my ($e, $channel, $user, $msg) = @_;
      if (my $match = $r->match("/$msg")) {
        $cb->($self, $channel, $user, $match, $msg);
      }
    }
  );
}

sub message {
  my ($self, $route, $cb) = @_;
  my $r = Mojolicious::Routes::Pattern->new($route);
  $self->bus->on(
    'message',
    sub {
      my ($e, $channel, $user, $msg) = @_;
      if (my $match = $r->match("/$msg")) {
        $cb->($self, $channel, $user, $match, $msg);
      }
    }
  );
}

1;

=head1 NAME

Marvin::App - Application superclass for Marvin 

=head1 DESCRIPTION

=head1 METHODS


=cut

__DATA__
