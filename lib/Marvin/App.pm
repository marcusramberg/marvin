package Marvin::App;

use Mojo::Base 'Mojolicious';
use Mojo::Loader 'load_class';
use Carp();

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
    my $class = 'Marvin::Adapter::' . $config->{adapter};
    if (my $e = load_class($class)) {
      die ref $e ? "Exception: $e" : "$class not found!";
    }
    my $adapter = $class->new(config => $config->{adapter_config});

    $adapter->setup;
    push @{$self->adapters}, $adapter;
  }
  $self->SUPER::start(@_);
}


1;
