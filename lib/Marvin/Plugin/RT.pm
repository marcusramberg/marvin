package Marvin::Plugin::RT;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use experimental 'signatures';

has 'ua' => sub { Mojo::UserAgent->new };
has 'config';

sub register($self,$app,$config) {
  $self->config($app->config);
  $self->{seen} = 0;
  $self->setup_take($app);
  $self->setup_poll($app);
}

sub setup_poll($self,$app) {

  Mojo::IOLoop->recurring(
    20 => sub {
      for my $queue (keys %{$self->config->{rt}->{queues}}) {
        my $url
          = $self->rt_url_for(
          "search/ticket?orderby=-created&format=s&query=Owner=%27Nobody%27 AND (Status=%27new%27 or Status=%27open%27) AND Queue=%27$queue%27"
          );
        $self->ua->post(
          $url,
          form => {
            user => $self->config->{rt}->{user},
            pass => $self->config->{rt}->{pass}
          },
          sub($ua,$tx) {
            my @messages = reverse split /\n/, $tx->res->body;
            my $first_run = !($self->{seen} || 0);
            for my $message (@messages) {
              utf8::decode($message);
              last unless $message =~ /^(?<ticket>\d+):(?<subject>.+)$/;
              next if $self->{seen} >= $+{ticket};
              $self->{seen} = $+{ticket};
              next if $first_run;
              $app->log->debug("Notifying: $+{ticket}");
              $app->bus->emit(
                notify => $self->config->{rt}->{queues}->{$queue},
                "[$queue] $+{subject} "
                  . $self->config->{rt}->{server}
                  . "/Ticket/Display.html?id=$+{ticket}"
              );
            }
          }
        );
      }
    }
  );
}

sub setup_take($self,$app) {
  Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $app->public('!take :ticket', $delay->begin);
    },
    sub {
      my ($delay, $channel, $user, $match, $msg) = @_;
      $delay->{channel} = $channel;
      $delay->{ticket}  = $match->{ticket};
      ($delay->{user}) = $user =~ m/^([^@]+)/;

      my $ticket
        = $self->ua->get($self->rt_url_for("ticket/$delay->{ticket}/show"),
        $delay->begin);
    },
    sub {
      my ($delay, $tx) = @_;
      unless ($tx->success) {
        return $app->bus->emit(
          notify => $delay->{channel},
          'Dave is not here right now.'
        );
      }
      my $ticket = parse_rt($tx->res->body);
      unless ($ticket->{Id}) {
        return $app->bus->emit(
          notify => $delay->{channel},
          'Could not find that ticket'
        );
      }

      if ($ticket->{Owner}) {
        return $app->bus->emit(
          notify => $delay->{channel},
          "$delay->{ticket} already taken by $ticket->{Owner}"
        );
      }
      $self->ua->post(
        $self->rt_url_for("ticket/$delay->{ticket}/edit"),
        form => {content => "Owner:$delay->{user}"},
        $delay->begin
      );
    },
    sub {
      my ($delay, $tx) = @_;
      if ($tx->success) {
        return $app->bus->emit(
          notify => $delay->{channel},
          "Sigh. Here I am, brain the size of a planet, and you ask me to assign you a ticket. fine."
        );
      }
      return $app->bus->emit(
        notify => $delay->{channel},
        "This will all end in tears."
      );
    }
  );
}

sub rt_url_for($self, $path) {
  return Mojo::URL->new($self->config->{rt}->{server} . '/REST/1.0/' . $path);
}

sub parse_rt($body) {
  my $ticket = {};
  for my $line (split /\n/, $body) {
    if ($line =~ m/^(.+)\*s\:\s*(.+)$/) {
      $ticket->{$1} = $2;
    }
  }
  return $ticket;
}

1;
