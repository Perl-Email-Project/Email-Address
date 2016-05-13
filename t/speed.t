#!perl
use strict;

use Email::Address;
use Test::More tests => 1;

my $email = "\"Hello\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\" <\@m>";
my ($ea) = Email::Address->parse($email);

is(
  $ea,
  undef,
  'Bad address does not parse, but is not really slow'
);

