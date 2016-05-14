use strict;
use warnings;
package Email::Address;
# ABSTRACT: RFC 2822 Address Parsing and Creation

our $STRINGIFY ||= 'format';
our $UNICODE   ||= 0;

=head1 SYNOPSIS

  use Email::Address;

  my @addresses = Email::Address->parse($line);
  my $address   = Email::Address->new(Casey => 'casey@localhost');

  print $address->format;

=head1 DESCRIPTION

This class implements a regex-based RFC 2822 parser that locates email
addresses in strings and returns a list of C<Email::Address> objects found.
Alternatively you may construct objects manually. The goal of this software is
to be correct, and very very fast.

=cut

my $CTL            = q{\x00-\x1F\x7F};
my $special        = q{()<>\\[\\]:;@\\\\,."};

my $quoted_pair    = qr/\\[[:graph:] \t]/;

my $ctext          = qr/[^$CTL()\\]/;
my $comment        = qr/(?<comment>\((?:$ctext|$quoted_pair|(?&comment))*\))/;
my $cfws           = qr/(?>$comment|\s+)/;

my $atext          = qq/[^$CTL$special\\s]/;
my $atom           = qr/$cfws*(?>$atext+)$cfws*/;
my $dot_atom_text  = qr/$atext+(?:\.$atext+)*/;
my $dot_atom       = qr/$cfws*(?>$dot_atom_text)$cfws*/;

my $qtext          = qr/[^$CTL\\"]/;
my $qcontent       = qr/$qtext|$quoted_pair/;
my $quoted_string  = qr/$cfws*"(?>$qcontent*)"$cfws*/;

my $word           = qr/$atom|$quoted_string/;

my $obs_phrase     = qr/$word(?>(?:$word|\.|$cfws)*)/;
my $phrase         = qr/$obs_phrase|(?>$word+)/;

my $local_part     = qr/$dot_atom|$quoted_string/;
my $dtext          = qr/[^$CTL\[\]\\]/;
my $domain_literal = qr/$cfws*\[(?>$dtext*)\]$cfws*/;
my $domain         = qr/$dot_atom|$domain_literal/;

my $display_name   = $phrase;

# This is for extracting comments, but not from inside quoted strings or domain
# literals; or quoted strings from in phrases.
my $parts = qr/("(?>$qcontent*)")|(\[(?>$dtext*)\])|$comment|([^\["(]+)/;

=head2 Package Variables

B<ACHTUNG!>  Email isn't easy (if even possible) to parse with a regex, I<at
least> if you're on a C<perl> prior to 5.10.0.  Providing regular expressions
for use by other programs isn't a great idea, because it makes it hard to
improve the parser without breaking the "it's a regex" feature.  Using these
regular expressions is not encouraged, and methods like C<<
Email::Address->is_addr_spec >> should be provided in the future.

Several regular expressions used in this package are useful to others.
For convenience, these variables are declared as package variables that
you may access from your program.

These regular expressions conform to the rules specified in RFC 2822.

You can access these variables using the full namespace. If you want
short names, define them yourself.

  my $addr_spec = $Email::Address::addr_spec;

=over 4

=item $Email::Address::addr_spec

This regular expression defined what an email address is allowed to
look like.

=item $Email::Address::angle_addr

This regular expression defines an C<$addr_spec> wrapped in angle
brackets.

=item $Email::Address::name_addr

This regular expression defines what an email address can look like
with an optional preceding display name, also known as the C<phrase>.

=item $Email::Address::mailbox

This is the complete regular expression defining an RFC 2822 email
address with an optional preceding display name and optional
following comment.

=back

=cut

our $addr_spec  = qr/(?<local_part>$local_part)\@(?<domain>$domain)/;
our $angle_addr = qr/$cfws*<$addr_spec>$cfws*/;
our $name_addr  = qr/(?<display_name>$display_name?)$angle_addr/;
our $mailbox    = qr/$name_addr|$addr_spec/;

sub _PHRASE   () { 0 }
sub _ADDRESS  () { 1 }
sub _COMMENT  () { 2 }
sub _ORIGINAL () { 3 }
sub _IN_CACHE () { 4 }

sub __dump {
  return {
    phrase   => $_[0][_PHRASE],
    address  => $_[0][_ADDRESS],
    comment  => $_[0][_COMMENT],
    original => $_[0][_ORIGINAL],
  }
}

=head2 Class Methods

=over

=item parse

  my @addrs = Email::Address->parse(
    q[me@local, Casey <me@local>, "Casey" <me@local> (West)]
  );

This method returns a list of C<Email::Address> objects it finds in the input
string.  B<Please note> that it returns a list, and expects that it may find
multiple addresses.  The behavior in scalar context is undefined.

By default, this module mandates that email addresses be ASCII only, and any
non-ASCII content will cause a blank result. This matches RFCs 822, 2822, and
5322. If you wish to allow UTF-8 characters in email, as per RFCs 5335 and
6532, set C<$Email:Address::UNICODE> to 1.

=cut

our (%PARSE_CACHE, %FORMAT_CACHE, %NAME_CACHE);
my $NOCACHE;

sub __get_cached_parse {
    return if $NOCACHE;

    my ($class, $line) = @_;

    return @{$PARSE_CACHE{$line}} if exists $PARSE_CACHE{$line};
    return;
}

sub __cache_parse {
    return if $NOCACHE;

    my ($class, $line, $addrs) = @_;

    $PARSE_CACHE{$line} = $addrs;
}

sub parse {
    my ($class, $line) = @_;
    return unless $line;

    if (my @cached = $class->__get_cached_parse($line)) {
        return @cached;
    }

    my @addrs;
    while ($line =~ /(?<mailbox>$mailbox)/go) {
      local $_ = $+{mailbox};
      my $original = $_;
      my $phrase = $+{display_name};
      my $user = $+{local_part};
      my $host = $+{domain};

      unless ($UNICODE) {
          next if $user =~ /\P{ASCII}/;
          next if $host =~ /\P{ASCII}/;
      }

      my @comments;
      my $new = '';
      while (/$parts/go) {
          my ($q, $d, $c, $o) = ($1, $2, $3, $4);
          $new .= $q, next if $q;
          $new .= $d, next if $d;
          $new .= $o, next if $o;
          push @comments, $c;
      }
      $_ = $new;

      for ( $phrase, $host, $user, @comments ) {
        next unless defined $_;
        s/^\s+//;
        s/\s+$//;
        $_ = undef unless length $_;
      }

      $new = '';
      while ($phrase && $phrase =~ /$parts/go) {
        my ($q, $d, $c, $o) = ($1, $2, $3, $4);
        $new .= $d, next if $d; # Shouldn't be any
        $new .= $c, next if $c; # Shouldn't be any
        $new .= $o, next if $o;
        $q =~ s/\A"(.+)"\z/$1/;
        $q =~ s/\\(.)/$1/g;
        $new .= $q;
      }
      $phrase = $new if $new;

      my $new_comment = join q{ }, @comments;
      push @addrs,
        $class->new($phrase, "$user\@$host", $new_comment, $original);
      $addrs[-1]->[_IN_CACHE] = [ \$line, $#addrs ]
    }

    $class->__cache_parse($line, \@addrs);
    return @addrs;
}

=item new

  my $address = Email::Address->new(undef, 'casey@local');
  my $address = Email::Address->new('Casey West', 'casey@local');
  my $address = Email::Address->new(undef, 'casey@local', '(Casey)');

Constructs and returns a new C<Email::Address> object. Takes four
positional arguments: phrase, email, and comment, and original string.

If phrase starts and ends with quotes, the phrase will be assumed to be a
quoted string. Otherwise it will be treated as is.

The original string should only really be set using C<parse>.

=cut

sub new {
  my ($class, $phrase, $email, $comment, $orig) = @_;
  $phrase = _dephrase($phrase) if $phrase;

  bless [ $phrase, $email, $comment, $orig ] => $class;
}

sub _dephrase {
    my $phrase = shift;
    return $phrase unless $phrase =~ /\A"(.+)"\z/;
    $phrase =~ s/\A"(.+)"\z/$1/;
    $phrase =~ s/($quoted_pair)/substr $1, -1/goe;
    return $phrase;
}

=item purge_cache

  Email::Address->purge_cache;

One way this module stays fast is with internal caches. Caches live
in memory and there is the remote possibility that you will have a
memory problem. On the off chance that you think you're one of those
people, this class method will empty those caches.

I've loaded over 12000 objects and not encountered a memory problem.

=cut

sub purge_cache {
    %NAME_CACHE   = ();
    %FORMAT_CACHE = ();
    %PARSE_CACHE  = ();
}

=item disable_cache

=item enable_cache

  Email::Address->disable_cache if memory_low();

If you'd rather not cache address parses at all, you can disable (and
re-enable) the Email::Address cache with these methods.  The cache is enabled
by default.

=cut

sub disable_cache {
  my ($class) = @_;
  $class->purge_cache;
  $NOCACHE = 1;
}

sub enable_cache {
  $NOCACHE = undef;
}

=back

=head2 Instance Methods

=over 4

=item phrase

  my $phrase = $address->phrase;
  $address->phrase( "Me oh my" );

Accessor and mutator for the phrase portion of an address.

=item address

  my $addr = $address->address;
  $addr->address( "me@PROTECTED.com" );

Accessor and mutator for the address portion of an address.

=item comment

  my $comment = $address->comment;
  $address->comment( "(Work address)" );

Accessor and mutator for the comment portion of an address.

=item original

  my $orig = $address->original;

Accessor for the original address found when parsing, or passed
to C<new>.

=item host

  my $host = $address->host;

Accessor for the host portion of an address's address.

=item user

  my $user = $address->user;

Accessor for the user portion of an address's address.

=cut

BEGIN {
  my %_INDEX = (
    phrase   => _PHRASE,
    address  => _ADDRESS,
    comment  => _COMMENT,
    original => _ORIGINAL,
  );

  for my $method (keys %_INDEX) {
    no strict 'refs';
    my $index = $_INDEX{ $method };
    *$method = sub {
      if ($_[1]) {
        if ($_[0][_IN_CACHE]) {
          my $replicant = bless [ @{$_[0]} ] => ref $_[0];
          $PARSE_CACHE{ ${ $_[0][_IN_CACHE][0] } }[ $_[0][_IN_CACHE][1] ]
            = $replicant;
          $_[0][_IN_CACHE] = undef;
        }
        $_[0]->[ $index ] = $_[1];
      } else {
        $_[0]->[ $index ];
      }
    };
  }
}

sub host { ($_[0]->[_ADDRESS] =~ /\@($domain)/o)[0]     }
sub user { ($_[0]->[_ADDRESS] =~ /($local_part)\@/o)[0] }

=pod

=item format

  my $printable = $address->format;

Returns a properly formatted RFC 2822 address representing the
object.

=cut

sub format {
    my $cache_str = do { no warnings 'uninitialized'; "@{$_[0]}" };
    return $FORMAT_CACHE{$cache_str} if exists $FORMAT_CACHE{$cache_str};
    $FORMAT_CACHE{$cache_str} = $_[0]->_format;
}

sub _format {
    my ($self) = @_;

    unless (
      defined $self->[_PHRASE] && length $self->[_PHRASE]
      ||
      defined $self->[_COMMENT] && length $self->[_COMMENT]
    ) {
        return defined $self->[_ADDRESS] ? $self->[_ADDRESS] : '';
    }

    my $comment = defined $self->[_COMMENT] ? $self->[_COMMENT] : '';
    $comment = "($comment)" if length $comment and $comment !~ /\A\(.*\)\z/;

    my $format = sprintf q{%s <%s> %s},
                 $self->_enquoted_phrase,
                 (defined $self->[_ADDRESS] ? $self->[_ADDRESS] : ''),
                 $comment;

    $format =~ s/^\s+//;
    $format =~ s/\s+$//;

    return $format;
}

sub _enquoted_phrase {
  my ($self) = @_;

  my $phrase = $self->[_PHRASE];

  return '' unless defined $phrase and length $phrase;

  # if it's encoded -- rjbs, 2007-02-28
  return $phrase if $phrase =~ /\A=\?.+\?=\z/;

  $phrase = _dephrase($phrase);
  $phrase =~ s/([\\"])/\\$1/g;

  return qq{"$phrase"};
}

=item name

  my $name = $address->name;

This method tries very hard to determine the name belonging to the address.
First the C<phrase> is checked. If that doesn't work out the C<comment>
is looked into. If that still doesn't work out, the C<user> portion of
the C<address> is returned.

This method does B<not> try to massage any name it identifies and instead
leaves that up to someone else. Who is it to decide if someone wants their
name capitalized, or if they're Irish?

=cut

sub name {
    my $cache_str = do { no warnings 'uninitialized'; "@{$_[0]}" };
    return $NAME_CACHE{$cache_str} if exists $NAME_CACHE{$cache_str};

    my ($self) = @_;
    my $name = q{};
    if ( $name = $self->[_PHRASE] ) {
        $name = _dephrase($name);
    } elsif ( $name = $self->[_COMMENT] ) {
        $name =~ s/^\(//;
        $name =~ s/\)$//;
        $name =~ s/($quoted_pair)/substr $1, -1/goe;
        $name =~ s/$comment/ /go;
    } else {
        ($name) = $self->[_ADDRESS] =~ /($local_part)\@/o;
    }
    $NAME_CACHE{$cache_str} = $name;
}

=back

=head2 Overloaded Operators

=over 4

=item stringify

  print "I have your email address, $address.";

Objects stringify to C<format> by default. It's possible that you don't
like that idea. Okay, then, you can change it by modifying
C<$Email:Address::STRINGIFY>. Please consider modifying this package
variable using C<local>. You might step on someone else's toes if you
don't.

  {
    local $Email::Address::STRINGIFY = 'host';
    print "I have your address, $address.";
    #   geeknest.com
  }
  print "I have your address, $address.";
  #   "Casey West" <casey@geeknest.com>

Modifying this package variable is now deprecated. Subclassing is now the
recommended approach.

=cut

sub as_string {
  warn 'altering $Email::Address::STRINGIFY is deprecated; subclass instead'
    if $STRINGIFY ne 'format';

  $_[0]->can($STRINGIFY)->($_[0]);
}

use overload '""' => 'as_string', fallback => 1;

=pod

=back

=cut

1;

__END__

=head2 Did I Mention Fast?

On his 1.8GHz Apple MacBook, rjbs gets these results:

  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 5
                   Rate  Mail::Address Email::Address
  Mail::Address  2.59/s             --           -44%
  Email::Address 4.59/s            77%             --

  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 25
                   Rate  Mail::Address Email::Address
  Mail::Address  2.58/s             --           -67%
  Email::Address 7.84/s           204%             --

  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 50
                   Rate  Mail::Address Email::Address
  Mail::Address  2.57/s             --           -70%
  Email::Address 8.53/s           232%             --

...unfortunately, a known bug causes a loss of speed the string to parse has
certain known characteristics, and disabling cache will also degrade
performance.

=head1 ACKNOWLEDGEMENTS

Thanks to Kevin Riggle and Tatsuhiko Miyagawa for tests for annoying
phrase-quoting bugs!

=cut

