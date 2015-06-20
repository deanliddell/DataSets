#!/usr/bin/env perl
#
use strict;
use warnings;
use constant { LineFeed => "\n" };

my $RECORD;             # each line read from input stream.
my $GROUP_1;            # regexp capture group.
my $GROUP_2;            # regexp capture group.

# Read input stream. Output is STDOUT
# which is returned as a stream.
#
while ($RECORD = <>) {
    chomp $RECORD; # remove line-feed carriage-return.
        #
        # Is the value too short?
        #
    if (length($RECORD) < 4) {
        print "0000", LineFeed;
        #
        # Is this a four-digit number?
        #
    } elsif ($RECORD =~ /^\d{4}$/) {
        #
        # Is this a valid 24-hour clock number?
        #
        if ($RECORD =~ /^([01][0-9]|2[0-3])[0-5][0-9]/) {
            print $RECORD, LineFeed;
        } else {
            print "0000", LineFeed;
        }
        #
        # Does this value have four-digits + something else?
        #
    } elsif ($RECORD =~ /^(\d{4})([[:alpha:]]|[[:punct:]])+$/) {
        #
        # Then extract the four-digits and validate them.
        #
        $GROUP_1 = $1;
        if ($GROUP_1 =~ /^([01][0-9]|2[0-3])[0-5][0-9]/) {
            print $GROUP_1, LineFeed;
        } else {
            print "0000", LineFeed;
        }
        #
        # Is this value a mix of 12-/24-hour clock notation with meridians?
        #
    } elsif ($RECORD =~ /^(\d{2}):(\d{2}):(\d{2}) (AM|PM)$/) {
        #
        # Do this in two-parts: 1) extract 'AM'  numbers  and validate, then 
        # 2) extract 'PM' numbers and validate. Time shift (i.e. -12 or +12) 
        # for numbers recorded as 12-hour clock instead of 24-hour clock.
        #
        $GROUP_1 = $1 . $2;
        $GROUP_2 = $4;
        if ($GROUP_2 =~ /AM/) {
            if ($GROUP_1 =~ /^(0[0-9]|1[0-1])[0-5][0-9]/) {
                print $GROUP_1, LineFeed;
            } else {
                #
                # AM numbers > 1159.
                #
                print sprintf("%04d", $GROUP_1 - 1200), LineFeed;
            }
        } else { 
            if ($GROUP_1 =~ /^(1[2-9]|2[0-3])[0-5][0-9]/) {
                print $GROUP_1, LineFeed;
            } else {
                #
                # PM numbers < 1200.
                #
                print sprintf("%04d", $GROUP_1 + 1200), LineFeed;
            }
        }
        #
        # Are we now left with nonsense values?
        #
    } elsif ($RECORD =~ /^([[:alpha:]]|[[:punct:]])/) {
        #
        # Just return midnight.
        #
        print "0000", LineFeed;
        #
        # And do the same thing as default on
        # any value for which there is no test.
        #
    } else {
        print "0000", LineFeed;
    }
}

__END__
