use Test::More;

use_ok 'Marvin::Adapter::IRC';
my $adapter = Marvin::Adapter::IRC->new;
isa_ok($adapter, Marvin::Adapter::IRC);

done_testing;
