package Marvin::Adapter::IRC;

use Mojo::Base 'Marvin::Adapter';
use experimental 'signatures';

use Mojo::IRC;

has 'client';

sub register($self, $app) {
  my $config = $self->config;
  $self->client(
    Mojo::IRC->new(
      nick   => $config - {nick},
      user   => $config->{user},
      server => $config->{server}
    )
  );
  $self->client->connect(
    sub($irc,$err) {
      $irc->write(join => $_) for (@{$config->{rooms}});
    }
  );
  $self->client->on(
    irc_join => sub {
      my ($self, $message) = @_;
      my $room = $message->{params}[0];
      $app->bus->emit(joined => $room);
      $self->{rooms}->{$room} = 1;
    }
  );

  $self->client->on(
    privmsg => sub($self,$msg) {
      my $from = $message->{params}[0];
      $app->bus->emit(message => $from, $msg->from, $1);
    }
  );
}

1;
