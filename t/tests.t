use Test::More tests => 1096;
use strict;
$^W = 1;

# This is a corpus of addresses to test.  Each element of @list is a pair of
# input and expected output.  The input is a string that will be given to
# Email::Address, with "-- ATAT --" replaced with the encircled a.
#
# The output is a list of formatted addresses we expect to extract from the
# string.

my @list = (
  [
    '',
    []
  ],
  [
    '"\'\'\'advocacy-- ATAT --perl.org \' \' \'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'\'\'advocacy-- ATAT --perl.org \' \' \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'\'advocacy-- ATAT --perl.org \' \'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'\'advocacy-- ATAT --perl.org \' \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'. Jerry a\'" <JerryPanshen-- ATAT --aol.com>',
    [
      [
        '"\'. Jerry a\'"',
        'JerryPanshen-- ATAT --aol.com',
        undef
      ]
    ]
  ],
  [
    '"\'Adam Turoff\'" <adam.turoff-- ATAT --isinet.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"\'Adam Turoff\'"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Andy Lester\'" <andy-- ATAT --petdance.com>, "\'Gabor Szabo\'" <gabor-- ATAT --tracert.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"\'Andy Lester\'"',
        'andy-- ATAT --petdance.com',
        undef
      ],
      [
        '"\'Gabor Szabo\'"',
        'gabor-- ATAT --tracert.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Ask Bjoern Hansen\'" <ask-- ATAT --perl.org>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Ask Bjoern Hansen\'"',
        'ask-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com> , "\'David E. Wheeler\'" <David-- ATAT --wheeler.net>',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        '"\'David E. Wheeler\'"',
        'David-- ATAT --wheeler.net',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com> , "\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu>',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com> , "\'Jon Orwant\'" <orwant-- ATAT --media.mit.edu>, <chip-- ATAT --valinux.com> , <tidbit-- ATAT --sri.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        '"\'Jon Orwant\'"',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com>, <advocacy-- ATAT --perl.org>, <perl5-porters-- ATAT --perl.org>',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'perl5-porters-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Chris Nandor\'" <pudge-- ATAT --pobox.com>, advocacy-- ATAT --perl.org, perl5-porters-- ATAT --perl.org',
    [
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'perl5-porters-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'David H. Adler \'" <dha-- ATAT --panix.com>, "\'advocacy-- ATAT --perl.org \'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'David H. Adler \'"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        '"\'advocacy-- ATAT --perl.org \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Doucette, Bob\'" <BDoucette-- ATAT --tesent.com>, \'Rich Bowen\' <rbowen-- ATAT --rcbowen.com>',
    [
      [
        '"\'Doucette, Bob\'"',
        'BDoucette-- ATAT --tesent.com',
        undef
      ],
      [
        '\'Rich Bowen\'',
        'rbowen-- ATAT --rcbowen.com',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton \'" <elaine-- ATAT --chaos.wustl.edu>, "Turoff, Adam" <adam.turoff-- ATAT --isinet.com>',
    [
      [
        '"\'Elaine -HFB- Ashton \'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Turoff, Adam"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu>',
    [
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu> , "\'Larry Wall\'" <larry-- ATAT --wall.org>',
    [
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"\'Larry Wall\'"',
        'larry-- ATAT --wall.org',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu> , "\'Larry Wall\'" <larry-- ATAT --wall.org> , "\'Jon Orwant\'" <orwant-- ATAT --media.mit.edu>, <chip-- ATAT --valinux.com> , <tidbit-- ATAT --sri.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"\'Larry Wall\'"',
        'larry-- ATAT --wall.org',
        undef
      ],
      [
        '"\'Jon Orwant\'"',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu>, "\'Larry Wall\'" <larry-- ATAT --wall.org>, "\'Jon Orwant\'" <orwant-- ATAT --media.mit.edu>, <chip-- ATAT --valinux.com>, <tidbit-- ATAT --sri.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"\'Larry Wall\'"',
        'larry-- ATAT --wall.org',
        undef
      ],
      [
        '"\'Jon Orwant\'"',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Elaine -HFB- Ashton\'" <elaine-- ATAT --chaos.wustl.edu>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Elaine -HFB- Ashton\'"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'John Porter\'" <jdporter-- ATAT --min.net>, "\'advocacy-- ATAT --perl.org\'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'John Porter\'"',
        'jdporter-- ATAT --min.net',
        undef
      ],
      [
        '"\'advocacy-- ATAT --perl.org\'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Larry Wall\'" <larry-- ATAT --wall.org> , "\'Jon Orwant\'" <orwant-- ATAT --media.mit.edu>, <chip-- ATAT --valinux.com> , <tidbit-- ATAT --sri.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Larry Wall\'"',
        'larry-- ATAT --wall.org',
        undef
      ],
      [
        '"\'Jon Orwant\'"',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Madeline Schnapp \'" <madeline-- ATAT --oreilly.com>, "\'advocacy-- ATAT --perl.org \'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Madeline Schnapp \'"',
        'madeline-- ATAT --oreilly.com',
        undef
      ],
      [
        '"\'advocacy-- ATAT --perl.org \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Mark Mielke\'" <markm-- ATAT --nortelnetworks.com>',
    [
      [
        '"\'Mark Mielke\'"',
        'markm-- ATAT --nortelnetworks.com',
        undef
      ]
    ]
  ],
  [
    '"\'Pamela Carter\'" <pcarter150-- ATAT --comcast.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'Pamela Carter\'"',
        'pcarter150-- ATAT --comcast.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Shlomi Fish\'" <shlomif-- ATAT --vipe.technion.ac.il>',
    [
      [
        '"\'Shlomi Fish\'"',
        'shlomif-- ATAT --vipe.technion.ac.il',
        undef
      ]
    ]
  ],
  [
    '"\'Steve Lane\'" <sml-- ATAT --zfx.com>, "\'Chris Nandor\'" <pudge-- ATAT --pobox.com>, advocacy-- ATAT --perl.org, perl5-porters-- ATAT --perl.org',
    [
      [
        '"\'Steve Lane\'"',
        'sml-- ATAT --zfx.com',
        undef
      ],
      [
        '"\'Chris Nandor\'"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'perl5-porters-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'Tom Christiansen\'" <tchrist-- ATAT --chthon.perl.com>, Horsley Tom <Tom.Horsley-- ATAT --ccur.com>, "\'Steve Lane\'" <sml-- ATAT --zfx.com>, advocacy-- ATAT --perl.org, perl5-porters-- ATAT --perl.org',
    [
      [
        '"\'Tom Christiansen\'"',
        'tchrist-- ATAT --chthon.perl.com',
        undef
      ],
      [
        'Horsley Tom',
        'Tom.Horsley-- ATAT --ccur.com',
        undef
      ],
      [
        '"\'Steve Lane\'"',
        'sml-- ATAT --zfx.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'perl5-porters-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'abigail-- ATAT --foad.org\'" <abigail-- ATAT --foad.org>,	 "Michael R. Wolf"<MichaelRunningWolf-- ATAT --att.net>',
    [
      [
        '"\'abigail-- ATAT --foad.org\'"',
        'abigail-- ATAT --foad.org',
        undef
      ],
      [
        '"Michael R. Wolf"',
        'MichaelRunningWolf-- ATAT --att.net',
        undef
      ]
    ]
  ],
  [
    '"\'abigail-- ATAT --foad.org\'" <abigail-- ATAT --foad.org>, Michael G Schwern <schwern-- ATAT --pobox.com>',
    [
      [
        '"\'abigail-- ATAT --foad.org\'"',
        'abigail-- ATAT --foad.org',
        undef
      ],
      [
        'Michael G Schwern',
        'schwern-- ATAT --pobox.com',
        undef
      ]
    ]
  ],
  [
    '"\'abigail-- ATAT --foad.org\'" <abigail-- ATAT --foad.org>, Michael G Schwern <schwern-- ATAT --pobox.com>, Nicholas Clark <nick-- ATAT --ccl4.org>, Piers Cawley <pdcawley-- ATAT --bofh.org.uk>, advocacy-- ATAT --perl.org',
    [
      [
        '"\'abigail-- ATAT --foad.org\'"',
        'abigail-- ATAT --foad.org',
        undef
      ],
      [
        'Michael G Schwern',
        'schwern-- ATAT --pobox.com',
        undef
      ],
      [
        'Nicholas Clark',
        'nick-- ATAT --ccl4.org',
        undef
      ],
      [
        'Piers Cawley',
        'pdcawley-- ATAT --bofh.org.uk',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'advocacy-- ATAT --perl.org \'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'advocacy-- ATAT --perl.org \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'advocacy-- ATAT --perl.org \'" <advocacy-- ATAT --perl.org>, "Turoff, Adam" <adam.turoff-- ATAT --isinet.com>',
    [
      [
        '"\'advocacy-- ATAT --perl.org \'"',
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        '"Turoff, Adam"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ]
    ]
  ],
  [
    '"\'advocacy-- ATAT --perl.org\'" <advocacy-- ATAT --perl.org>',
    [
      [
        '"\'advocacy-- ATAT --perl.org\'"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'bwarnock-- ATAT --capita.com\'" <bwarnock-- ATAT --capita.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"\'bwarnock-- ATAT --capita.com\'"',
        'bwarnock-- ATAT --capita.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"\'duff-- ATAT --pobox.com\'" <duff-- ATAT --pobox.com>',
    [
      [
        '"\'duff-- ATAT --pobox.com\'"',
        'duff-- ATAT --pobox.com',
        undef
      ]
    ]
  ],
  [
    '"\'london-list-- ATAT --happyfunball.pm.org\'" <london-list-- ATAT --happyfunball.pm.org>',
    [
      [
        '"\'london-list-- ATAT --happyfunball.pm.org\'"',
        'london-list-- ATAT --happyfunball.pm.org',
        undef
      ]
    ]
  ],
  [
    '"\'perl-hackers-- ATAT --stlouis.pm.org\'" <perl-hackers-- ATAT --stlouis.pm.org>',
    [
      [
        '"\'perl-hackers-- ATAT --stlouis.pm.org\'"',
        'perl-hackers-- ATAT --stlouis.pm.org',
        undef
      ]
    ]
  ],
  [
    '"\'perl-hackers-- ATAT --stlouis.pm.org\'" <perl-hackers-- ATAT --stlouis.pm.org>, advocacy-- ATAT --perl.org, marsneedswomen-- ATAT --happyfunball.pm.org',
    [
      [
        '"\'perl-hackers-- ATAT --stlouis.pm.org\'"',
        'perl-hackers-- ATAT --stlouis.pm.org',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'marsneedswomen-- ATAT --happyfunball.pm.org',
        undef
      ]
    ]
  ],
  [
    '"<advocacy-- ATAT --perl.org>" <advocacy-- ATAT --perl.org>',
    [
      [
        'advocacy',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Adam Turoff" <adam.turoff-- ATAT --isinet.com>, "Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>',
    [
      [
        '"Adam Turoff"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ],
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ]
    ]
  ],
  [
    '"Adam Turoff" <adam.turoff-- ATAT --isinet.com>, "Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "Brent Michalski" <brent-- ATAT --perlguy.net>, "Madeline Schnapp" <madeline-- ATAT --oreilly.com>, <advocacy-- ATAT --perl.org>, <betsy-- ATAT --oreilly.com>',
    [
      [
        '"Adam Turoff"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ],
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Brent Michalski"',
        'brent-- ATAT --perlguy.net',
        undef
      ],
      [
        '"Madeline Schnapp"',
        'madeline-- ATAT --oreilly.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'betsy-- ATAT --oreilly.com',
        undef
      ]
    ]
  ],
  [
    '"Adam Turoff" <adam.turoff-- ATAT --isinet.com>, "Paul Prescod" <paul-- ATAT --prescod.net>',
    [
      [
        '"Adam Turoff"',
        'adam.turoff-- ATAT --isinet.com',
        undef
      ],
      [
        '"Paul Prescod"',
        'paul-- ATAT --prescod.net',
        undef
      ]
    ]
  ],
  [
    '"Alan Olsen" <alan-- ATAT --clueserver.org>, "Rich Bowen" <rbowen-- ATAT --rcbowen.com>',
    [
      [
        '"Alan Olsen"',
        'alan-- ATAT --clueserver.org',
        undef
      ],
      [
        '"Rich Bowen"',
        'rbowen-- ATAT --rcbowen.com',
        undef
      ]
    ]
  ],
  [
    '"Andreas J. Koenig" <andreas.koenig-- ATAT --anima.de>',
    [
      [
        '"Andreas J. Koenig"',
        'andreas.koenig-- ATAT --anima.de',
        undef
      ]
    ]
  ],
  [
    '"Andreas J. Koenig" <andreas.koenig-- ATAT --anima.de>, advocacy-- ATAT --perl.org',
    [
      [
        '"Andreas J. Koenig"',
        'andreas.koenig-- ATAT --anima.de',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Andreas J. Koenig" <andreas.koenig-- ATAT --anima.de>, advocacy-- ATAT --perl.org, regn-- ATAT --ActiveState.com',
    [
      [
        '"Andreas J. Koenig"',
        'andreas.koenig-- ATAT --anima.de',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'regn-- ATAT --ActiveState.com',
        undef
      ]
    ]
  ],
  [
    '"Andy Wardley" <abw-- ATAT --cre.canon.co.uk>',
    [
      [
        '"Andy Wardley"',
        'abw-- ATAT --cre.canon.co.uk',
        undef
      ]
    ]
  ],
  [
    '"Bas A. Schulte" <bschulte-- ATAT --zeelandnet.nl>',
    [
      [
        '"Bas A. Schulte"',
        'bschulte-- ATAT --zeelandnet.nl',
        undef
      ]
    ]
  ],
  [
    '"Bas A.Schulte" <bschulte-- ATAT --zeelandnet.nl>',
    [
      [
        '"Bas A.Schulte"',
        'bschulte-- ATAT --zeelandnet.nl',
        undef
      ]
    ]
  ],
  [
    '"Betsy Waliszewski" <betsy-- ATAT --oreilly.com>, "perl-advocacy" <advocacy-- ATAT --perl.org>',
    [
      [
        '"Betsy Waliszewski"',
        'betsy-- ATAT --oreilly.com',
        undef
      ],
      [
        '"perl-advocacy"',
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Bradley M. Kuhn" <bkuhn-- ATAT --ebb.org>',
    [
      [
        '"Bradley M. Kuhn"',
        'bkuhn-- ATAT --ebb.org',
        undef
      ]
    ]
  ],
  [
    '"Brammer, Phil" <PBRA01-- ATAT --CONAGRAFROZEN.COM>',
    [
      [
        '"Brammer, Phil"',
        'PBRA01-- ATAT --CONAGRAFROZEN.COM',
        undef
      ]
    ]
  ],
  [
    '"Brent Michalski" <brent-- ATAT --perlguy.net>, "Madeline Schnapp" <madeline-- ATAT --oreilly.com>, <advocacy-- ATAT --perl.org>, <betsy-- ATAT --oreilly.com>',
    [
      [
        '"Brent Michalski"',
        'brent-- ATAT --perlguy.net',
        undef
      ],
      [
        '"Madeline Schnapp"',
        'madeline-- ATAT --oreilly.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'betsy-- ATAT --oreilly.com',
        undef
      ]
    ]
  ],
  [
    '"Brian Wilson" <bwilson-- ATAT --songline.com>',
    [
      [
        '"Brian Wilson"',
        'bwilson-- ATAT --songline.com',
        undef
      ]
    ]
  ],
  [
    '"Calvin Lee" <bodyshock911-- ATAT --hotmail.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Calvin Lee"',
        'bodyshock911-- ATAT --hotmail.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Calvin Lee" <bodyshock911-- ATAT --hotmail.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"Calvin Lee"',
        'bodyshock911-- ATAT --hotmail.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Chip Salzenberg" <chip-- ATAT --valinux.com>',
    [
      [
        '"Chip Salzenberg"',
        'chip-- ATAT --valinux.com',
        undef
      ]
    ]
  ],
  [
    '"Chip Salzenberg" <chip-- ATAT --valinux.com>, "Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>',
    [
      [
        '"Chip Salzenberg"',
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ]
    ]
  ],
  [
    '"Chris Devers" <cdevers-- ATAT --boston.com>, "Uri Guttman" <uri-- ATAT --stemsystems.com>',
    [
      [
        '"Chris Devers"',
        'cdevers-- ATAT --boston.com',
        undef
      ],
      [
        '"Uri Guttman"',
        'uri-- ATAT --stemsystems.com',
        undef
      ]
    ]
  ],
  [
    '"Chris Nandor" <pudge-- ATAT --pobox.com>',
    [
      [
        '"Chris Nandor"',
        'pudge-- ATAT --pobox.com',
        undef
      ]
    ]
  ],
  [
    '"Chris Nandor" <pudge-- ATAT --pobox.com>, "Nathan Torkington" <gnat-- ATAT --frii.com>, "Peter Scott" <Peter-- ATAT --PSDT.com>',
    [
      [
        '"Chris Nandor"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        '"Nathan Torkington"',
        'gnat-- ATAT --frii.com',
        undef
      ],
      [
        '"Peter Scott"',
        'Peter-- ATAT --PSDT.com',
        undef
      ]
    ]
  ],
  [
    '"Chris Nandor" <pudge-- ATAT --pobox.com>, "Nathan Torkington" <gnat-- ATAT --frii.com>, <advocacy-- ATAT --perl.org>, "Peter Scott" <Peter-- ATAT --PSDT.com>',
    [
      [
        '"Chris Nandor"',
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        '"Nathan Torkington"',
        'gnat-- ATAT --frii.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        '"Peter Scott"',
        'Peter-- ATAT --PSDT.com',
        undef
      ]
    ]
  ],
  [
    '"Clinton A. Pierce" <clintp-- ATAT --geeksalad.org>',
    [
      [
        '"Clinton A. Pierce"',
        'clintp-- ATAT --geeksalad.org',
        undef
      ]
    ]
  ],
  [
    '"Clinton A. Pierce" <clintp-- ATAT --geeksalad.org>, madeline-- ATAT --oreilly.com, pudge-- ATAT --pobox.com, advocacy-- ATAT --perl.org',
    [
      [
        '"Clinton A. Pierce"',
        'clintp-- ATAT --geeksalad.org',
        undef
      ],
      [
        undef,
        'madeline-- ATAT --oreilly.com',
        undef
      ],
      [
        undef,
        'pudge-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Curtis Poe" <cp-- ATAT --onsitetech.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Curtis Poe"',
        'cp-- ATAT --onsitetech.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Curtis Poe" <cp-- ATAT --onsitetech.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"Curtis Poe"',
        'cp-- ATAT --onsitetech.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Dave Cross" <dave-- ATAT --dave.org.uk>',
    [
      [
        '"Dave Cross"',
        'dave-- ATAT --dave.org.uk',
        undef
      ]
    ]
  ],
  [
    '"David E. Wheeler" <David-- ATAT --Wheeler.net>',
    [
      [
        '"David E. Wheeler"',
        'David-- ATAT --Wheeler.net',
        undef
      ]
    ]
  ],
  [
    '"David E. Wheeler" <David-- ATAT --Wheeler.net>, "\'Larry Wall\'" <larry-- ATAT --wall.org>, "\'Jon Orwant\'" <orwant-- ATAT --media.mit.edu>, chip-- ATAT --valinux.com, tidbit-- ATAT --sri.net, advocacy-- ATAT --perl.org',
    [
      [
        '"David E. Wheeler"',
        'David-- ATAT --Wheeler.net',
        undef
      ],
      [
        '"\'Larry Wall\'"',
        'larry-- ATAT --wall.org',
        undef
      ],
      [
        '"\'Jon Orwant\'"',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'chip-- ATAT --valinux.com',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"David E. Wheeler" <David-- ATAT --Wheeler.net>, \'Elaine -HFB- Ashton\' <elaine-- ATAT --chaos.wustl.edu>, \'Larry Wall\' <larry-- ATAT --wall.org>, \'Jon Orwant\' <orwant-- ATAT --media.mit.edu>, tidbit-- ATAT --sri.net, advocacy-- ATAT --perl.org',
    [
      [
        '"David E. Wheeler"',
        'David-- ATAT --Wheeler.net',
        undef
      ],
      [
        '\'Elaine -HFB- Ashton\'',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '\'Larry Wall\'',
        'larry-- ATAT --wall.org',
        undef
      ],
      [
        '\'Jon Orwant\'',
        'orwant-- ATAT --media.mit.edu',
        undef
      ],
      [
        undef,
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"David Grove" <pete-- ATAT --petes-place.com>',
    [
      [
        '"David Grove"',
        'pete-- ATAT --petes-place.com',
        undef
      ]
    ]
  ],
  [
    '"David Grove" <pete-- ATAT --petes-place.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"David Grove"',
        'pete-- ATAT --petes-place.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"David H. Adler" <dha-- ATAT --panix.com>',
    [
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ]
    ]
  ],
  [
    '"David H. Adler" <dha-- ATAT --panix.com>, <advocacy-- ATAT --perl.org>, <simon-- ATAT --brecon.co.uk>',
    [
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'simon-- ATAT --brecon.co.uk',
        undef
      ]
    ]
  ],
  [
    '"David H. Adler" <dha-- ATAT --panix.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"David H. Adler" <dha-- ATAT --panix.com>, advocacy-- ATAT --perl.org, perl5-porters-- ATAT --perl.org',
    [
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'perl5-porters-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"David H. Adler" <dha-- ATAT --panix.com>,advocacy-- ATAT --perl.org',
    [
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Edwards, Darryl" <Darryl.Edwards-- ATAT --adc.com>',
    [
      [
        '"Edwards, Darryl"',
        'Darryl.Edwards-- ATAT --adc.com',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "Brent Michalski" <brent-- ATAT --perlguy.net>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Brent Michalski"',
        'brent-- ATAT --perlguy.net',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "Frank Schmuck, CFO" <fschmuck-- ATAT --lcch.org>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Frank Schmuck, CFO"',
        'fschmuck-- ATAT --lcch.org',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "Peter Scott" <Peter-- ATAT --PSDT.com>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Peter Scott"',
        'Peter-- ATAT --PSDT.com',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "Tom Christiansen" <tchrist-- ATAT --chthon.perl.com>, <Ben_Tilly-- ATAT --trepp.com>, "David H. Adler" <dha-- ATAT --panix.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"Tom Christiansen"',
        'tchrist-- ATAT --chthon.perl.com',
        undef
      ],
      [
        undef,
        'Ben_Tilly-- ATAT --trepp.com',
        undef
      ],
      [
        '"David H. Adler"',
        'dha-- ATAT --panix.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, "brian d foy" <tidbit-- ATAT --sri.net>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        '"brian d foy"',
        'tidbit-- ATAT --sri.net',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Elaine -HFB- Ashton" <elaine-- ATAT --chaos.wustl.edu>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Elaine -HFB- Ashton"',
        'elaine-- ATAT --chaos.wustl.edu',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Frank Schmuck, CFO" <fschmuck-- ATAT --lcch.org>',
    [
      [
        '"Frank Schmuck, CFO"',
        'fschmuck-- ATAT --lcch.org',
        undef
      ]
    ]
  ],
  [
    '"Frank Schmuck, CFO" <fschmuck-- ATAT --lcch.org>, "\'abigail-- ATAT --foad.org\'" <abigail-- ATAT --foad.org>, Michael G Schwern <schwern-- ATAT --pobox.com>,  Nicholas Clark <nick-- ATAT --ccl4.org>, advocacy-- ATAT --perl.org',
    [
      [
        '"Frank Schmuck, CFO"',
        'fschmuck-- ATAT --lcch.org',
        undef
      ],
      [
        '"\'abigail-- ATAT --foad.org\'"',
        'abigail-- ATAT --foad.org',
        undef
      ],
      [
        'Michael G Schwern',
        'schwern-- ATAT --pobox.com',
        undef
      ],
      [
        'Nicholas Clark',
        'nick-- ATAT --ccl4.org',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"G. Wade Johnson" <gwadej-- ATAT --anomaly.org>',
    [
      [
        '"G. Wade Johnson"',
        'gwadej-- ATAT --anomaly.org',
        undef
      ]
    ]
  ],
  [
    '"Gabor Szabo" <gabor-- ATAT --tracert.com>',
    [
      [
        '"Gabor Szabo"',
        'gabor-- ATAT --tracert.com',
        undef
      ]
    ]
  ],
  [
    '"Greg Norris (humble visionary genius)" <nextrightmove-- ATAT --yahoo.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Greg Norris"',
        'nextrightmove-- ATAT --yahoo.com',
        '(humble visionary genius)'
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Greg Norris \\(humble visionary genius\\)" <nextrightmove-- ATAT --yahoo.com>',
    [
      [
        '"Greg Norris \\(humble visionary genius\\)"',
        'nextrightmove-- ATAT --yahoo.com',
        undef
      ]
    ]
  ],
  [
    '"Greg Norris humble visionary genius\\"" <nextrightmove-- ATAT --yahoo.com>',
    [
      [
        '"Greg Norris humble visionary genius\\""',
        'nextrightmove-- ATAT --yahoo.com',
        undef
      ]
    ]
  ],
  [
    '"Helton, Brandon" <bhelton-- ATAT --harris.com>, perl6-language-- ATAT --perl.org, advocacy-- ATAT --perl.org',
    [
      [
        '"Helton, Brandon"',
        'bhelton-- ATAT --harris.com',
        undef
      ],
      [
        undef,
        'perl6-language-- ATAT --perl.org',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [
    '"Jan Dubois" <jand-- ATAT --ActiveState.com>',
    [
      [
        '"Jan Dubois"',
        'jand-- ATAT --ActiveState.com',
        undef
      ]
    ]
  ],
  [
    '"Jason W. May" <jasonmay-- ATAT --pacbell.net>',
    [
      [
        '"Jason W. May"',
        'jasonmay-- ATAT --pacbell.net',
        undef
      ]
    ]
  ],
  [
    '"Jason W. May" <jmay-- ATAT --pobox.com>',
    [
      [
        '"Jason W. May"',
        'jmay-- ATAT --pobox.com',
        undef
      ]
    ]
  ],
  [
    '"Jason W. May" <jmay-- ATAT --pobox.com>, <advocacy-- ATAT --perl.org>',
    [
      [
        '"Jason W. May"',
        'jmay-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ],
  [ 
    'Jason W. May <jmay-- ATAT --pobox.com>',                                   
    [                                                                           
      [                                                                         
        'Jason W. May',                                                         
        'jmay-- ATAT --pobox.com',                                              
        undef                                                                   
      ]                                                                         
    ]                                                                           
  ],                                                                            
  [
    '"Jason W. May" <jmay-- ATAT --pobox.com>, advocacy-- ATAT --perl.org',
    [
      [
        '"Jason W. May"',
        'jmay-- ATAT --pobox.com',
        undef
      ],
      [
        undef,
        'advocacy-- ATAT --perl.org',
        undef
      ]
    ]
  ]
);

use_ok 'Email::Address';

for (@list) {
  $_->[0] =~ s/-- ATAT --/@/g;
  my @addrs = Email::Address->parse($_->[0]);
  my @tests =
    map { Email::Address->new(map { $_ ? do {s/-- ATAT --/@/g; $_} : $_ } @$_) }
    @{$_->[1]};

  foreach (@addrs) {
      isa_ok($_, 'Email::Address');
      my $test = shift @tests;
      is($_->format, $test->format, "format: " .$test->format);
      is($_->as_string, $test->format, "format: " .$test->format);
      is("$_",       $test->format, "stringify: $_");
      is($_->name,   $test->name,   "name: " . $test->name);
  }
}
