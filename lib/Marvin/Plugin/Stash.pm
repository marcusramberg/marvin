package Marvin::Plugin::Stash;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;
use experimental 'signatures';

has 'ua' => sub { Mojo::UserAgent->new };
has 'config';

sub register($self,$app,$config) {
  $self->config($app->config);
  $self->{seen} = 0;
  $app->post('/web-hook' => \&web_hook);
}

sub web_hook($self) {
  for my $change (@{$self->req->json('/changesets/values')}) {
    my $slug = $self->req->json('/repository/slug');
    if (my $commit = $change->{toCommit}) {
      if (my $channel = $self->app->config->{stash}->{repos}->{$slug}) {
        my $message
          = "[$slug] $commit->{message} ($commit->{author}->{name}) "
          . $self->app->config->{stash}->{base}
          . $change->{link}->{url};
        $self->app->bus->emit(notify => $channel, $message);
      }
    }
    $self->render(text => 'OK');
  }
}

1;
