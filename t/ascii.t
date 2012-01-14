use strict;
use warnings;

use Test::More;

use Email::Address;
use Encode qw(decode);

my $ascii = q{admin@mozilla.org};
my $utf_8 = q{аdmin@mozilla.org};
my $text  = decode('utf-8', $utf_8, Encode::LEAVE_SRC);

{
  my (@addr) = Email::Address->parse($ascii);
  is(@addr, 1, "an ascii address is a-ok");

  # ok( $ascii =~ $Email::Address::addr_spec, "...it =~ addr_spec");
}

{
  my (@addr) = Email::Address->parse($utf_8);
  is(@addr, 0, "utf-8 octet address: not ok");

  # ok( $utf_8 !~ $Email::Address::addr_spec, "...it !~ addr_spec");
}

{
  my (@addr) = Email::Address->parse($text);
  is(@addr, 0, "unicode (decoded) address: not ok");

  # ok( $text =~ $Email::Address::addr_spec, "...it !~ addr_spec");
}

done_testing;
