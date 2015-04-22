package Marvin;

# Marvin uses sub signatures and requires 5.20.0;
use 5.20.0;

use Mojo::Base 'Marvin::App';

use File::Basename qw(basename dirname);
use File::Spec::Functions 'catdir';
use Mojo::UserAgent::Server;
use Mojo::Util 'monkey_patch';

use EV;

use experimental 'signatures';
use Carp qw/croak/;

sub import {

  # Remember executable for later
  $ENV{MOJO_EXE} ||= (caller)[1];

  # Reuse home directory if possible
  local $ENV{MOJO_HOME} = catdir split('/', dirname $ENV{MOJO_EXE})
    unless $ENV{MOJO_HOME};

  # Initialize application class
  my $caller = caller;
  no strict 'refs';
  push @{"${caller}::ISA"}, 'Mojo';

  # Generate moniker based on filename
  my $moniker = basename $ENV{MOJO_EXE};
  $moniker =~ s/\.(?:pl|pm|t)$//i;
  my $app = shift->new(moniker => $moniker);

  # Initialize routes without namespaces
  my $routes = $app->routes->namespaces([]);
  $app->static->classes->[0] = $app->renderer->classes->[0] = $caller;

  unshift @{$app->plugins->namespaces}, 'Marvin::Plugin';

  # The Mojolicious::Lite DSL
  my $root = $routes;
  for my $name (qw(any get options patch post put websocket)) {
    monkey_patch $caller, $name, sub { $routes->$name(@_) };
  }
  monkey_patch $caller, $_, sub {$app}
    for qw(new app);
  monkey_patch $caller, del => sub { $routes->delete(@_) };
  monkey_patch $caller,
    helper  => sub { $app->helper(@_) },
    hook    => sub { $app->hook(@_) },
    plugin  => sub { $app->plugin(@_) },
    message => sub { $app->message(@_) },
    public  => sub { $app->public(@_) },
    under   => sub { $routes = $root->under(@_) };

  # Make sure there's a default application for testing
  Mojo::UserAgent::Server->app($app) unless Mojo::UserAgent::Server->app;

  # Marvin apps are strict!
  Mojo::Base->import(-strict);

}


1;

=head1 NAME

Marvin - A bot framework built on Mojolicious

=head1 SYNOPSIS

  use Marvin;

  plugin 'Config';
<<<<<<< HEAD

  chat 'ping :host' => sub {
    my ($self, $msg,$channel,$nick,$host,$args)= @_;
    my $res=_ping($args->{host});
    $self->bus->emit(notify=>$channel,$res);
  };
  get '/hello' => sub {
    $self->bus->emit(notify=>app->config->{hello_channel},'Hello world');
  };
  message 'ping :host' => sub {
    my ($self, $channel, $user, $match, $msg)= @_;
    my $res=_ping($match->{host});
    $self->notify();
  };
  app->start;

=head1 DESCRIPTION

Marvin is a framework for writing chat bots. It's slanted towards devops
settings, but you could use it for any sort of chat channel. Just write 
plugins and endpoints 

=head1 COPYRIGHT

=head1 LICENSE

=cut
