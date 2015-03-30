package Marvin::Plugin::Console;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app, $config) = @_;
  $app->log->debug('Registered Console');
  $app->bus->on(
    message => sub {
      my ($e, $msg, $channel, $nick) = @_;
      $app->log->debug("<< [$channel] <$nick> $msg");
    },
    public => sub {
      my ($e, $msg, $channel, $nick) = @_;
      $app->log->debug("<< [$channel] <$nick> $msg");
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
