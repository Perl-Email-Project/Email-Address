use Email::Address;
$value = q{first@foo.org,} . q{ } x 26 . q{second@foo.org};
Email::Address->parse($value);
