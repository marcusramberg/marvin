package Marvin::Plugin::RT;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use experimental 'signatures';

has 'ua' => sub { Mojo::UserAgent->new };

sub register {
  my ($self, $app, $config) = @_;
  $config = $app->config;
  $self->{seen} = 0;
  Mojo::IOLoop->recurring(
    20 => sub {
      for my $queue (keys %{$config->{rt}->{queues}}) {
        my $url
          = "$config->{rt}->{server}/REST/1.0/search/ticket?orderby=-created&format=s&query=Owner=%27Nobody%27 AND (Status=%27new%27 or Status=%27open%27) AND Queue=%27$queue%27";
        warn "Triggered $url";
        $self->ua->post(
          $url,
          form =>
            {user => $config->{rt}->{user}, pass => $config->{rt}->{pass}},
          sub($ua,$tx) {
            my @messages = reverse split /\n/, $tx->res->body;
            for my $message (@messages) {
              utf8::decode($message);
              last unless $message =~ /^(?<ticket>\d+):(?<subject>.+)$/;
              $app->log->debug("Found ticket: $+{ticket}");
              next if $self->{seen} >= $+{ticket};
              $self->{seen} = $+{ticket};
              $app->bus->emit(
                notify => $config->{rt}->{queues}->{$queue},
                "[$queue] $+{subject} $config->{rt}->{server}/Ticket/Display.html?id=$+{ticket}"
              );
            }
          }
        );
      }
    }
  );

}

1;
