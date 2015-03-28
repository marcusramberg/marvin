package Marvin::Bus;

use Mojo::Base 'Mojo::EventEmitter';

1;

=head1 NAME

Marvin::Bus - Message bus for marvin

=head1 SYNOPSIS

  $app->bus->emit('message','#mojo','kraih','Hello world');
  $app->bus->on( join => sub { warn "JOINED" } );

=head1 DESCRIPTION

This is a message bus for Marvin. Plugins and routes can use it to 
communicate with the active  L<Marvin::Adapter>  subclasses.

It is a subclass of Mojo::EventEmitter.

=cut
