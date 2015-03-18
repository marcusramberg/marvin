package Marvin::App;

use Mojo::Base 'Mojolicious';
use Mojo::Loader 'load_class';
use Carp();

my @rooms = ();

has 'adapter';

sub start {
  my $self   = shift;
  my $config = $self->config;
  Carp::croak 'adapter must specified in configuration'
    unless $config->{adapter};
  my $class = 'Marvin::Adapter::' . $config->{adapter};
  if (my $e = load_class($class)) {
    die ref $e ? "Exception: $e" : "$class not found!";
  }
  my $adapter = $class->new(config => $config->{adapter_config});

  $adapter->setup;
  $self->adapter($adapter);
  $self->SUPER::start(@_);
}


1;
