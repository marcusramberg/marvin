package Marvin::Plugin::Console;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app, $config) = @_;
  $app->log->debug('Registered Console');
  $app->bus->on(
    message => sub {
      my ($e, $channel, $message) = @_;
      $app->log->debug("<< [$channel] $message");
    },
    notify => sub {
      my ($e, $channel, $message) = @_;
      $app->log->debug(">> [$channel] $message");
    },
    joined => sub {
      my ($e, $channel) = @_;
      $app->log->debug("Joined $channel");
    },
    parted => sub {
      my ($e, $channel) = @_;
      $app->log->debug("Parted $channel");
    },
  );
}

1;
