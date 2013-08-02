use strict;
use warnings;
use Email::Address;
use Test::More;

# [rt.cpan.org #15572]
my $str    = q{"Foo Bar <decoy@domain.foo>" <actual@otherdomain.foo>};
my ($addr) = Email::Address->parse($str);
is($addr->phrase,  'Foo Bar <decoy@domain.foo>', "phrase correct");
is($addr->address, 'actual@otherdomain.foo',     "address correct");

done_testing;
