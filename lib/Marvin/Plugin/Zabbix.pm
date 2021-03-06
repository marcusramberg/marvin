package Marvin::Plugin::Zabbix;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use Mojo::Util qw/dumper/;
use experimental 'signatures';
use DateTime::Format::Natural;
use Net::DNS::Resolver;

has 'dt' => sub { DateTime::Format::Natural->new; };

has 'ua' => sub { Mojo::UserAgent->new };

has 'auth';


sub register($self, $app, $config) {
  $self->ua->post(
    $app->config->{zabbix}->{url},
    json => {
      jsonrpc => "2.0",
      method  => "user.login",
      params  => {
        user     => $app->config->{zabbix}->{user},
        password => $app->config->{zabbix}->{pass},
      },
      id   => 1,
      auth => undef
    },
    sub {
      my ($ua, $tx) = @_;
      my $res = $tx->success;
      return unless $res;
      $self->auth($res->json->{result});
    }
  );
  $app->public(
    '!downtime :host :tquanta :tscale *reason',
    sub {
      my ($e, $msg, $channel, $user, $nick, $match) = @_;
      use DDP;
      p @_;

      return $app->bus->emit(notify => $channel,
        "$nick: Sorry, zabbix hates me.")
        unless $self->auth;
      my $res   = Net::DNS::Resolver->new;
      my $query = $res->search($match->{host});
      if ($query) {
        foreach my $rr ($query->answer) {
          next unless $rr->type eq "A";
          $match->{host} = $rr->name;
        }
      }
      else {
        return $app->bus->emit(
          notify => $channel,
          "$nick: Sorry,  I couldn't resolve $match->{host}"
        );
      }

      my $start = time();
      my @dt    = $self->dt->parse_datetime_duration(
        "for $match->{tquanta} $match->{tscale}");
      if (!$self->dt->success) {
        return $app->bus->emit(
          notify => $channel,
          "$nick: What nonsense is $match->{tquanta} $match->{tscale}? "
            . $self->dt->error
        );
      }
      my $end      = $dt[1]->epoch;
      my $duration = $end - $start;

      Mojo::IOLoop->delay(
        sub {
          my $delay = shift;
          $self->ua->post(
            $app->config->{zabbix}->{url},
            json => {
              jsonrpc => "2.0",
              method  => "host.get",
              params  => {filter => {host => $match->{host}}},
              auth    => $self->auth,
              id      => 3
            },
            $delay->begin
          );
        },
        sub {
          my ($delay, $res) = @_;
          my $json = $res->success->json;
          warn dumper($json);
          $app->bus->emit(
            notify => $channel,
            "$nick : Could not find that host"
          ) unless $json->{result}->[0];
          $self->ua->post(
            $app->config->{zabbix}->{url},
            json => {
              jsonrpc => "2.0",
              method  => "maintenance.create",
              params  => {
                groupids         => [],
                hostids          => [$json->{result}->[0]->{hostid}],
                name             => "Maintenance for $match->{host}",
                maintenance_type => 0,
                description      => $match->{reason} || "downtime from chat",
                active_since     => $start,
                active_till      => $end,
                timeperiods      => [
                  {
                    timeperiod_type => 0,
                    start_date      => $start,
                    period          => $duration
                  }
                ],
              },
              auth => $self->auth,
              id   => 3,
            },
            $delay->begin
          );
        },
        sub {
          my ($ua, $tx) = @_;
          if (my $res = $tx->success) {
            my $body = $res->json;
            $app->bus->emit(
              notify => $channel,
              "$nick : "
                . (
                $body->{error}
                ? 'Zabbix hates me: ' . $body->{error}->{data}
                : 'Done. Remember, if you break it, you bought it.'
                )
            );
          }
        }
      );
    }
  );
}

1;
