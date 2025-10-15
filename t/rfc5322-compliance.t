#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Email::Address;

# Regression test for RFC 5322 compliance issue found in Koha
# Email::Address should reject addresses without proper TLD per RFC 5322

# Test addresses that should be INVALID (missing TLD)
my @invalid_addresses = (
    'test@gmail',
    'admin@server',
    'user@domain',
);

# Test addresses that should be VALID (proper FQDN)
my @valid_addresses = (
    'test@gmail.com',
    'user@localhost',  # localhost is a special case that may be valid
    'admin@server.example.com',
);

# Test that invalid addresses are rejected
for my $addr (@invalid_addresses) {
    my @parsed = Email::Address->parse($addr);
    is(scalar(@parsed), 0, "$addr should be rejected (missing TLD)");
}

# Test that valid addresses are accepted
for my $addr (@valid_addresses) {
    my @parsed = Email::Address->parse($addr);
    is(scalar(@parsed), 1, "$addr should be accepted (valid FQDN)");
}

done_testing();

__END__

=head1 NAME

rfc5322-compliance.t - Regression test for RFC 5322 compliance

=head1 DESCRIPTION

This test ensures Email::Address properly rejects email addresses that violate
RFC 5322 by lacking fully qualified domain names (FQDN).

Currently FAILS because Email::Address incorrectly accepts addresses like
'test@gmail' when they should be rejected per RFC 5322.
