package Mojolicious::Command::generate::marvin;

use Mojo::Base 'Mojolicious::Command';

use Mojo::Util qw(class_to_file class_to_path);

has description => 'Generate Marvin application directory structure';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, $name) = @_;
  $name ||= 'marvin';
  $self->render_to_rel_file("app",      "$name/marvin.pl",   $name);
  $self->render_to_rel_file("config",   "$name/marvin.conf", $name);
  $self->render_to_rel_file("cpanfile", "$name/cpanfile",    $name);
  $self->create_rel_dir("$name/log");
  $self->create_rel_dir("$name/lib");
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Command::generate::marvin - Marvin generator command

=head1 SYNOPSIS

  Usage: mojo generate marvin [NAME]

=head1 DESCRIPTION

L<Mojolicious::Command::generate::marvin> generates application directory
structures for fully functional L<Marvin> bots.

=head1 ATTRIBUTES

L<Mojolicious::Command::generate::marvin> inherits all attributes from
L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $app->description;
  $app            = $app->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $app->usage;
  $app      = $app->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

=head2 run

  $app->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut

__DATA__

@@ app 
#!/usr/bin/env perl
use lib 'lib';
use Marvin;

plugin 'Config';
plugin 'Console';

app->start;

1;


@@ config
{
  adapters => [
    {
      type    => 'IRC',
      user    => 'marvin',
      pass    => 'secret',
      host    => 'irc.freenode.org',
      nick    => 'marvin',
      rooms   => ['#marvin'],
      tagline => 'Oh god I\'m so depressed.',
    },
  ],
}

@@ cpanfile
requires 'AnyEvent::XMPP';
requires 'Mojo::IRC';
requires 'EV';
requires 'Mojolicious';
requires 'IO::Prompt';
requires 'XML::Twig';
