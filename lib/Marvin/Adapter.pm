package Marvin::Adapter;

use Mojo::Base 'Mojo::EventEmitter';
use Carp();

has 'config';

sub setup { Carp::croak 'Method "setup" not implemented by subclass' }

1;
