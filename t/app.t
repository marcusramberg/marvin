use Test::More;

use_ok('Marvin::App');

my $app = Marvin::App->new();
$app->config->{adapters} = [];
{
  isa_ok($app, 'Marvin::App');
  can_ok($app, 'public', 'message');

};
{
  my $message;
  $app->public(
    'oh hai',
    sub {
      shift;
      $message = \@_;
      Mojo::IOLoop->stop;
    }
  );

  $app->bus->emit(public => 'test', 'user', 'oh hai');
  $app->start;
  is_deeply($message, ['test', 'user', {}, 'oh hai'], 'Correct msg args');

};

{
  my $message;
  $app->message(
    'oh hai',
    sub {
      shift;
      $message = \@_;
      Mojo::IOLoop->stop;
    }
  );

  $app->bus->emit(message => 'test', 'user', 'oh hai');
  $app->start;
  is_deeply($message, ['test', 'user', {}, 'oh hai'], 'Correct msg args');

}

done_testing;
