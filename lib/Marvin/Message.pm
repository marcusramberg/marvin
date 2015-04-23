package Marvin::Message;

use Mojo::Base -strict;

has 'message';
has 'channel';
has 'nick';
has 'hostmask';
has 'matches';

1;

=head1 NAME 

Marvin::Message - Wrapper for marvin message events, both public and direct;

=head1 DESCRIPTION

This is the message object, it's passed to your chat and message actions. 

=head1 ATTRIBUTES

=head2 message

The message body of the message received by your bot.

=head2 channel

=head2 the channel where the message was generated, or undef if it was a direct message

=head2 nick

The nick that generated the message, can be used to generate responses, but does not uniquely
identify any users, as nicks can be changed at any time. Do not use for security purposes.

=head hostmask

The ident/server hostmask for a given user. Generally assumed to be useful for identification, 
depending on how paranoid you are, note however that some users might be connected from shared
hosts where other administrators have access. If security is critical you might consider 
using a passord in addition to host masks for identification.

=head2 matches

Placeholder matches for your chat route. This is typically a hash reference.

=head1 COPYRIGHT & LICENSE

This work is copyright 2015 Marcus Ramberg.
It is licensed under The Artistic License 2.0.

=cut
