# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-DetectSeparator.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
use FindBin ();

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


use Text::CSV::DetectSeparator;
ok(1); # If we made it this far, we're ok.

my $file1 = $FindBin::Bin.'/test.csv';
my $file2 = $FindBin::Bin.'/test2.csv';

my $detector = Text::CSV::DetectSeparator->new($file1);
ok($detector && ref $detector eq 'Text::CSV::DetectSeparator');
ok($detector->separator() eq ',');

$detector->file($file2);
ok($detector->separator() eq ';');
