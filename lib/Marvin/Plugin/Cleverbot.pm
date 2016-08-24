package Marvin::Plugin::Cleverbot;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use experimental 'signatures';
use DDP;

has 'ua' => sub { Mojo::UserAgent->new };

sub register($self, $app, $config) {
  $app->message(
    '*message',
    sub {
      my ($e, $msg, $channel, $user, $nick, $match) = @_;
      $self->ua->post(
        'https://cleverbot.io/1.0/ask',
        form => {
          user => $app->config->{cleverbot}->{user},
          key  => $app->config->{cleverbot}->{key},
          nick => $app->config->{cleverbot}->{nick},
          text => $match->{message}
        },
        sub {
          my ($ua, $tx) = @_;
          if (my $res = $tx->success) {
            my $body = $res->json;
            $app->bus->emit(
              notify => $channel,
              "$nick: "
                . (
                  $body->{status} eq 'success'
                ? $body->{response}
                : $body->{status}
                )
            );
          }
        }
      );
    }
  );
}

1;
