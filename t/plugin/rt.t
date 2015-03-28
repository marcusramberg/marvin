use Test::More;
use Test::Mojo;

use Marvin;

app->config({adapters => [], rt => {},});
app->home('../');
plugin 'RT';

my $t = Test::Mojo->new;


done_testing;
