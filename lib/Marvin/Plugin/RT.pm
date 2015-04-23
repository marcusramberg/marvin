package Marvin::Plugin::RT;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use experimental 'signatures';

has 'ua' => sub { Mojo::UserAgent->new };
has 'config';

has answers => sub {
  [
    "Ok, but I don't think you'll like it",
    "Good luck with that",
    "I bet you can't take another",
    "*sigh* OK",
    "A brain the size of a planet, and you ask me to assign you a trouble ticket. Here you go...",
    "I've been talking to the RT Server. It hates me",
    "Not that anyone care what I say, but that ticket now belongs to you",
    "Done. Now I've got a headache",
    "Ok. I think you ought to know I'm feeling very depressed",
    "Do you want me to sit in a corner and rust or just fall apart where I'm standing?",
    "Oh, not another one.",
    "I'd like you to know I didn't enjoy that at all"
  ];
};

sub register($self, $app, $config) {
  $self->config($app->config);
  $self->{seen} = 0;
  $self->setup_take($app);
  $self->setup_poll($app);
}

sub setup_poll($self, $app) {

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
  my $delay = shift;
  $app->public(
    '!take :ticket',
    sub {
      my ($e, $msg, $channel, $user, $nick, $match) = @_;
      Mojo::IOLoop->delay(
        sub {
          my $delay = shift;
          $delay->{channel} = $channel;
          $delay->{ticket}  = $match->{ticket};
          ($delay->{user}) = $user =~ m/^([^@]+)/;

          my $ticket = $self->ua->post(
            $self->rt_url_for("ticket/$delay->{ticket}/show"),
            form => {
              user => $self->config->{rt}->{user},
              pass => $self->config->{rt}->{pass}
            },
            $delay->begin
          );
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
          unless ($ticket->{id}) {
            return $app->bus->emit(
              notify => $delay->{channel},
              'Could not find that ticket'
            );
          }

          if ($ticket->{Owner} && $ticket->{Owner} ne 'Nobody') {
            return $app->bus->emit(
              notify => $delay->{channel},
              "$delay->{ticket} already taken by $ticket->{Owner} "
            );
          }
          $self->ua->post(
            $self->rt_url_for("ticket/$delay->{ticket}/edit"),
            form => {
              user    => $self->config->{rt}->{user},
              pass    => $self->config->{rt}->{pass},
              content => "Owner: $delay->{user}"
            },
            $delay->begin
          );
        },
        sub {
          my ($delay, $tx) = @_;
          if ($tx->success) {
            return $app->bus->emit(
              notify => $delay->{channel},
              $self->answers->[rand @{$self->answers}]
            );
          }
          return $app->bus->emit(
            notify => $delay->{channel},
            "This will all end in tears ."
          );
        }
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
    my ($key, $value) = split ': ', $line;
    if (defined $value) {
      $ticket->{$key} = $value;
    }
  }
  return $ticket;
}

1;
