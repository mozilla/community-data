#!/usr/bin/perl -w
#

use LWP::UserAgent;
use Text::CSV;
use IO::String;
use Data::Dumper;
use Text::Unaccent;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $csv = Text::CSV->new({binary => 1});
my @emails = ();

# Read inclusive range from command line
my ($from, $to) = @ARGV;
($from) || usage();
$to ||= $from;

$from =~ /^\d+$/ || usage();
$to =~ /^\d+$/ || usage();

if ($from > $to) {
    abort("Please specify a line number range, lowest number first.");
}

if ($from == 1) {
    abort("First line included in range, but first line is column headers.");
}

# Download file
my $ua = LWP::UserAgent->new;
$ua->cookie_jar({});

my $response = $ua->get("https://docs.google.com/spreadsheet/ccc?key=__KEY__&output=csv");

if (!$response->is_success) {
    abort("Couldn't get credits data from Google Docs.");
}

# Parse into CSV
my $credits_data_io = IO::String->new($response->decoded_content);

$csv->column_names("timestamp",
                   "name",
                   "sortkey",
                   "email",
                   "citation",
                   "evidence",
                   "notes");

$entries = $csv->getline_hr_all($credits_data_io);

# Make sure range is present
my $num_lines = scalar(@$entries);
if ($num_lines < $to) {
  abort("Range exceed size of sheet. Requested line $to but only $num_lines available.");
}

for (my $i = $from; $i <= $to; $i++) {
    my $entry = $entries->[$i - 1]; # Lines are 1-based, but array is 0-based

    my $name     = trim($entry->{'name'});
    my $sortkey  = trim($entry->{'sortkey'});
    my $email    = trim(lc($entry->{'email'}));
    my $citation = trim($entry->{'citation'});
    my $notes    = trim($entry->{'notes'});

    next if $notes ne "Y";

    # Deal with errant ' characters by stopping quote, starting new quote
    # with double quote characters, doing the single quote, then switching
    # back.
    # http://stackoverflow.com/questions/1250079/escaping-single-quotes-within-single-quoted-strings
    $citation =~ s/'/'"'"'/g;
    my $checkin  = $name . ' <' . $email . '>: "' . $citation . '"';

    if (!$sortkey) {
        # No specific sortkey given.
        # Names with > 2 parts default to assuming single family name for sort.
        $name =~ m/^(.*) ([^ ]+)$/;
        $sortkey = $2;
    }

    if (!$name || !$sortkey) {
        abort("Name or sortkey missing.");
    }

    # Make sortkey ASCII
    $sortkey = lc(unac_string('utf-8', $sortkey));

    # Check for duplicate
    open(my $NAMES, '<:encoding(utf8)', "../names.csv") || abort("Can't open names.csv");
    my %names;
    while (<$NAMES>) {
        chomp;
        my ($existing_name) = split(",");
        $names{$existing_name} = 1;
    }

    if ($names{$name}) {
        abort($name . " is a duplicate");
    }

    my $line = "$name,$sortkey";

    # Add name and commit
    system("echo $line >> ../names.csv");

    print "($sortkey) " . $checkin . "\n";

    system("git commit ../names.csv -m '$checkin'");

    push(@emails, $email);
}

print "Send email to: \n" . join(", ", @emails) . "\n\n";

sub usage {
    print "Usage: import <from> <to>\n";
    print "  where <from> and <to> are integer line numbers in the credits sheet.\n";
    exit(1);
}

sub trim {
    my ($string) = @_;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub abort {
    print STDERR $_[0] . "\n";
    if (@emails) {
        print "Send email to: \n" . join(", ", @emails) . "\n\n";
    }

    exit(1);
}

