use strict;
use warnings;

use Test::More;

use Email::Address;
use Encode qw(decode);

my $ascii = q{admin@mozilla.org};
my $utf_8 = q{аdmin@mozilla.org};
my $text  = decode('utf-8', $utf_8, Encode::LEAVE_SRC);

my $ascii_mixed = qq{"$text" <$ascii>};
my $utf8_mixed = qq{"$text" <$text>};

for (0..1) {
  local $Email::Address::UNICODE = $_;

  {
    my (@addr) = Email::Address->parse($ascii);
    is(@addr, 1, "an ascii address is a-ok");

    # ok( $ascii =~ $Email::Address::addr_spec, "...it =~ addr_spec");
  }

  {
    my (@addr) = Email::Address->parse($ascii_mixed);
    is(@addr, 1, "a quoted non-ascii phrase is a-ok with ascii email");
  }

  {
    my (@addr) = Email::Address->parse($utf8_mixed);
    is(@addr, $Email::Address::UNICODE, "a quoted non-ascii phrase with non-ascii email");
  }

  {
    my (@addr) = Email::Address->parse($utf_8);
    is(@addr, $Email::Address::UNICODE, "utf-8 octet address");

    # ok( $utf_8 !~ $Email::Address::addr_spec, "...it !~ addr_spec");
  }

  {
    my (@addr) = Email::Address->parse($text);
    is(@addr, $Email::Address::UNICODE, "unicode (decoded) address");

    # ok( $text =~ $Email::Address::addr_spec, "...it !~ addr_spec");
  }

  {
    my @addr = Email::Address->parse(qq{
      "Not ascii phras\x{e9}" <good\@email>,
      b\x{e3}d\@user,
      bad\@d\x{f6}main,
      not.bad\@again
    });
    is scalar @addr, $Email::Address::UNICODE ? 4 : 2, "correct number of good emails";
    is "$addr[0]", qq{"Not ascii phras\x{e9}" <good\@email>}, "expected email";
    if ($Email::Address::UNICODE) {
      is "$addr[1]", qq{b\x{e3}d\@user}, "expected email";
      is "$addr[2]", qq{bad\@d\x{f6}main}, "expected email";
      is "$addr[3]", qq{not.bad\@again}, "expected email";
    } else {
      is "$addr[1]", qq{not.bad\@again}, "expected email";
    }
  }

  Email::Address->purge_cache;

}

done_testing;
