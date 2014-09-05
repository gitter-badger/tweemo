#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use DBI;
use DBD::SQLite;
use FindBin qw($RealBin $RealScript);
use Getopt::Long;
use Statistics::Lite qw(mean);

sub usage {
    print <<EOM;
usage: $RealScript 'message'
EOM
    exit;
}

my $D = "\t"; # delimiter
my $treetagger = 'tree-tagger-english';

# Tag Set https://courses.washington.edu/hypertxt/csar-v02/penntable.html
my $v_regex = qr/^(VB|VBD|VBG|VBN|VBZ|VBP|VD|VDD|VDG|VHN|VHZ|VHP|VV|VVD|VVG|VVN|VVP|VVZ)$/;
my $n_regex = qr/^(NN|NNS|NP|NPS|PP)$/;
my $a_regex = qr/^(JJ|JJR|JJS)$/;
my $r_regex = qr/^(RB|RBR|RBS)$/;

my $MSG = $ARGV[0];
my $DB = "$RealBin/db/pn_en.dic.db";
my $HELP;

GetOptions(
    'help' => \$HELP,
);

&usage() if $HELP;

my $dbh = DBI->connect("dbi:SQLite:dbname=$DB", undef, undef, 
    {AutoCommit => 0, RaiseError => 1 });
$dbh->{sqlite_unicode} = 1;

my $s = $MSG;
$s =~ s/"/\\"/g;
my @res = split(/\n/, `echo "$s" |$treetagger 2>/dev/null`);
my @os = ();
for (@res) {
    if (/^.+$D(.+)$D(.+)$/) {
        my($p, $l) = ($1, $2);
        if ($p =~ $v_regex) {
            # verb
            push @os, &get_orient($dbh, $l, 'v');
        } elsif ($p =~ $n_regex) {
            # noun
            push @os, &get_orient($dbh, $l, 'n');
        } elsif ($p =~ $a_regex) {
            # adjective
            push @os, &get_orient($dbh, $l, 'a');
        } elsif ($p =~ $r_regex) {
            # adverb
            push @os, &get_orient($dbh, $l, 'r');
        }
    }
}

$dbh->commit;
$dbh->disconnect;

my $val = @os ? int(mean(@os) * (10**4)) / (10**4) : 0;
$MSG .= " ($val)";
print $MSG;

exit;


sub get_orient {
    my($dbh, $w, $p) = @_;
    my $sth = $dbh->prepare("SELECT orient FROM dictionary WHERE word=? AND pos=?;");
    $sth->execute($w, $p);
    while (my $hr = $sth->fetchrow_arrayref) {
        return $hr->[0] + 0;
    }
    return 0;
}
