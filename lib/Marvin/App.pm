package Marvin::App;

use Mojo::Base 'Mojolicious';
use Mojo::Loader 'load_class';
use Carp();
use IO::Prompt;

has adapters => sub { [] };

sub start {
  my $self     = shift;
  my $config   = $self->config;
  my $adapters = $config->{adapters};
  Carp::croak 'adapters must be a list of hashes'
    unless $adapters
    && ref $adapters eq 'ARRAY'
    && ref $adapters->[0] eq 'HASH';
  for my $adapter (@$adapters) {
    my $class = 'Marvin::Adapter::' . $adapter->{type};
    if (my $e = load_class($class)) {
      die ref $e ? "Exception: $e" : "$class not found!";
    }
    my $adapter = $class->new(config => $adapter);

    $adapter->register;
    push @{$self->adapters}, $adapter;
  }
  $self->SUPER::start(@_);
}

has password => sub { prompt('password: ', -e => '*'); };
1;
