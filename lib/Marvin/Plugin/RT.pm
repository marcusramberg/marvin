package Marvin::Plugin::RT;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app, $config) = @_;
  my $seen = 0;
  Mojo::IOLoop->recurring(
    20 => sub {
      $self->app->->post(
        "https://rt.uio.no/REST/1.0/search/ticket?orderby=-created&format=s&query=Owner=%27Nobody%27 AND (Status=%27new%27 or Status=%27open%27) AND Queue=%27www-drift%27",
        form => {user => 'marcusr', pass => $config->{pass}},
        sub($ua,$tx) {
          my @messages = reverse split /\n/, $tx->res->body;
          for my $message (@messages) {
            utf8::decode($message);
            last unless $message =~ /^(?<ticket>\d+):(?<subject>.+)$/;
            $app->log->debug("Found ticket: $+{ticket}");
            next if $seen >= $+{ticket};
            $self->emit(message =>
                "[www-drift] $+{subject} https://rt.uio.no/Ticket/Display.html?id=$+{ticket}"
            );
          }
        }
      }
      );
  }
  );

}

1;
