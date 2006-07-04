package Email::Address;
# $Id: Address.pm,v 1.8 2004/10/22 16:39:14 cwest Exp $
use strict;

use vars qw[$VERSION $COMMENT_NEST_LEVEL $STRINGIFY
            %PARSE_CACHE %FORMAT_CACHE %NAME_CACHE
            $addr_spec $angle_addr $name_addr $mailbox];

$VERSION              = '1.80';
$COMMENT_NEST_LEVEL ||= 2;
$STRINGIFY          ||= 'format';

=head1 NAME

Email::Address - RFC 2822 Address Parsing and Creation

=head1 SYNOPSIS

  use Email::Address;

  my @addresses = Email::Address->parse($line);
  my $address   = Email::Address->new(Casey => 'casey@localhost');

  print $address->format;

=head1 DESCRIPTION

This class implements a complete RFC 2822 parser that locates email
addresses in strings and returns a list of C<Email::Address> objects
found. Alternatley you may construct objects manually. The goal
of this software is to be correct, and very very fast.

=cut

my $CTL            = q[\x00-\x1F\x7F];
my $special        = q[()<>\\[\\]:;@\\,."];

my $text           = qr/[^\x0A\x0D]/;

my $quoted_pair    = qr/\\$text/;

my $ctext          = qr/(?>[^()\\]+)/;
my ($ccontent, $comment) = ('')x2;
for (1 .. $COMMENT_NEST_LEVEL) {
   $ccontent       = qr/$ctext|$quoted_pair|$comment/;
   $comment        = qr/\s*\((?:\s*$ccontent+)*\s*\)\s*/;
}
my $cfws           = qr/$comment+|\s+/;

my $atext          = qq/[^$CTL$special\\s]/;
my $atom           = qr/$cfws*$atext+$cfws*/;
my $dot_atom_text  = qr/$atext+(?:\.$atext+)*/;
my $dot_atom       = qr/$cfws*$dot_atom_text$cfws*/;

my $qtext          = qr/[^\\"]/;
my $qcontent       = qr/$qtext|$quoted_pair/;
my $quoted_string  = qr/$cfws*"$qcontent+"$cfws*/;

my $word           = qr/$atom|$quoted_string/;
my $phrase         = qr/$word+/;

my $local_part     = qr/$dot_atom|$quoted_string/;
my $dtext          = qr/[^\[\]\\]/;
my $dcontent       = qr/$dtext|$quoted_pair/;
my $domain_literal = qr/$cfws*\[(?:\s*$dcontent+)*\s*\]$cfws*/;
my $domain         = qr/$dot_atom|$domain_literal/;

my $display_name   = $phrase;

=head2 Package Variables

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
with an optional preceeding display name, also known as the C<phrase>.

=item $Email::Address::mailbox

This is the complete regular expression defining an RFC 2822 emial
address with an optional preceeding display name and optional
following comment.

=back

=cut

$addr_spec  = qr/$local_part\@$domain/;
$angle_addr = qr/$cfws*<$addr_spec>$cfws*/;
$name_addr  = qr/$display_name?$angle_addr/;
$mailbox    = qr/(?:$name_addr|$addr_spec)$comment*/;

=head2 Class Methods

=over 4

=item parse

  my @addrs = Email::Address->parse(
      q[me@local, Casey <me@local>, "Casey" <me@local> (West)]
  );

This method returns a list of C<Email::Address> objects it finds
in the input string.

The specification for an email address allows for infinitley
nestable comments. That's nice in theory, but a little over done.
By default this module allows for two (C<2>) levels of nested
comments. If you think you need more, modify the
C<$Email::Address::COMMENT_NEST_LEVEL> package variable to allow
more.

  $Email::Address::COMMENT_NEST_LEVEL = 10; # I'm deep

The reason for this hardly limiting limitation is simple: efficiency.

=cut

sub parse {
    return @{$PARSE_CACHE{$_[1]}} if exists $PARSE_CACHE{$_[1]};
    my ($class, $line) = @_;
    my (@mailboxes) = ($line =~ /$mailbox/go);
    my @addrs;
    foreach (@mailboxes) {
      my $original = $_;

      my @comments = /($comment)/go;
      s/$comment//go if @comments;

      my ($user, $host, $com);
      ($user, $host) = ($1, $2) if s/<($local_part)\@($domain)>//o;
      if (! defined($user) || ! defined($host)) {
          s/($local_part)\@($domain)//o;
          ($user, $host) = ($1, $2);
      }

      my ($phrase)       = /($display_name)/o;

      for ( $phrase, $host, $user, @comments ) {
        next unless defined $_;
        s/^\s+//;
        s/\s+$//;
      }

      my $new_comment = join ' ', @comments;
      push @addrs, $class->new($phrase, "$user\@$host", $new_comment, $original);
    }
    $PARSE_CACHE{$line} = [@addrs];
    @addrs;
}

=pod

=item new

  my $address = Email::Address->new(undef, 'casey@local');
  my $address = Email::Address->new('Casey West', 'casey@local');
  my $address = Email::Address->new(undef, 'casey@local', '(Casey)');

Constructs and returns a new C<Email::Address> object. Takes four
positional arguments: phrase, email, and comment, and original string.

The original string should only really be set using C<parse>.

=cut

sub _PHRASE   () { 0 }
sub _ADDRESS  () { 1 }
sub _COMMENT  () { 2 }
sub _ORIGINAL () { 3 }
sub new { bless [@_[1..4]], $_[0] }

=pod

=item purge_cache

  Email::Address->purge_cache;

One way this module stays fast is with internal caches. Caches live
in memory and there is the remote possibility that you will have a
memory problem. In the off chance that you think you're one of those
people, this class method will empty those caches.

I've loaded over 12000 objects and not encountered a memory problem.

=cut

sub purge_cache {
    %NAME_CACHE   = ();
    %FORMAT_CACHE = ();
    %PARSE_CACHE  = ();
}

=pod

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

sub phrase   { $_[1] ? $_[0]->[_PHRASE]   = $_[1] : $_[0]->[_PHRASE]   }
sub address  { $_[1] ? $_[0]->[_ADDRESS]  = $_[1] : $_[0]->[_ADDRESS]  }
sub comment  { $_[1] ? $_[0]->[_COMMENT]  = $_[1] : $_[0]->[_COMMENT]  }
sub original { $_[1] ? $_[0]->[_ORIGINAL] = $_[1] : $_[0]->[_ORIGINAL] }
sub host     { ($_[0]->[_ADDRESS] =~ /\@($domain)/o)[0]                }
sub user     { ($_[0]->[_ADDRESS] =~ /($local_part)\@/o)[0]            }


=pod

=item format

  my $printable = $address->format;

Returns a properly formatted RFC 2822 address representing the
object.

=cut

sub format {
    local $^W = 0;
    return $FORMAT_CACHE{"@{$_[0]}"} if exists $FORMAT_CACHE{"@{$_[0]}"};
    my ($self) = @_;
    my $format = sprintf '%s <%s> %s',
                 $self->[_PHRASE], $self->[_ADDRESS], $self->[_COMMENT];
    $format =~ s/^\s+//;
    $format =~ s/\s+$//;
    $FORMAT_CACHE{"@{$_[0]}"} = $format;
}

=pod

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
    local $^W = 0;
    return $NAME_CACHE{"@{$_[0]}"} if exists $NAME_CACHE{"@{$_[0]}"};
    my ($self) = @_;
    my $name = '';
    if ( $name = $self->[_PHRASE] ) {
        $name =~ s/^"//;
        $name =~ s/"$//;
        $name =~ s/($quoted_pair)/substr $1, -1/goe;
    } elsif ( $name = $self->[_COMMENT] ) {
        $name =~ s/^\(//;
        $name =~ s/\)$//;
        $name =~ s/($quoted_pair)/substr $1, -1/goe;
        $name =~ s/$comment/ /go;
    } else {
        ($name) = $self->[_ADDRESS] =~ /($local_part)\@/o;
    }
    $NAME_CACHE{"@{$_[0]}"} = $name;
}

=pod

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
    local $Email::Address::STRINGIFY = 'address';
    print "I have your address, $address.";
    #   geeknest.com
  }
  print "I have your address, $address.";
  #   "Casey West" <casey@geeknest.com>

=cut

sub as_string { no strict 'refs'; goto &{$STRINGIFY} };
use overload '""' => \&as_string;

=pod

=back

=cut

1;

__END__

=head2 Did I Mention Fast?

On my 877Mhz 12" Apple Powerbook I can run the distributed benchmarks and
get results like this.

  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 5 
                 s/iter  Mail::Address Email::Address
  Mail::Address    1.59             --           -31%
  Email::Address   1.10            45%             --
  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 25
                 s/iter  Mail::Address Email::Address
  Mail::Address    1.58             --           -60%
  Email::Address  0.630           151%             --
  $ perl -Ilib bench/ea-vs-ma.pl bench/corpus.txt 50
                 s/iter  Mail::Address Email::Address
  Mail::Address    1.58             --           -65%
  Email::Address  0.558           182%             --

=head1 SEE ALSO

L<Email::Simple>, L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
