#!perl
use strict;

use Email::Address;
use Test::More tests => 2;

my $email = "\"Hello\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\" <\@m>";
my ($ea) = Email::Address->parse($email);

is(
  $ea,
  undef,
  'Bad address does not parse, but is not really slow'
);

my $email = '\(¯¯`·.¥«P®ÎÑç€ØfTh€ÐÅ®K»¥.·`¯¯\) <email () example com>, "(> \" \" <)                              ( =\'o\'= )                              (\")___(\")  sWeEtAnGeLtHePrInCeSsOfThEsKy" <email2 () example com>, "(i)cRiStIaN(i)" <email3 () example com>, "(S)MaNu_vuOLeAmMazZaReNimOe(*)MiAo(@)" <email4 () example com>';
my $email2 = ", $email";
$email = $email . ($email2 x 10);
my @emails = Email::Address->parse($email);

is(@emails, 0, 'Bad addresses do not parse, but do not take for ever');
