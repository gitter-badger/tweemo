#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use DBI;
use DBD::SQLite;
use Encode qw(decode);
use FindBin qw($RealBin $RealScript);
use Getopt::Long;
use Statistics::Lite qw(mean);

sub usage {
    print <<EOM;
usage: $RealScript 'message'
EOM
    exit;
}

my $v_regex = qr/^動詞$/;
my $n_regex = qr/^名詞$/;
my $a_regex = qr/^形容詞$/;
my $r_regex = qr/^副詞$/;
my $av_regex = qr/^助動詞$/;

my $MSG = $ARGV[0];
my $DB = "$RealBin/db/pn_ja.dic.db";
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
my @res = split(/\n/, `echo "$s" |mecab`);
my @os = ();
for (@res) {
    if (/^.+\t(.+),.+,.+,.+,.+,.+,(.+),(.+),.+$/) {
        my($p, $w, $r) = ($1, $2, $3);
        $p = decode('UTF-8', $p);
        $w = decode('UTF-8', $w);
        $r = decode('UTF-8', $r);
        if ($p =~ $v_regex) {
            # verb
            push @os, &get_orient($dbh, $w, $r, '動詞');
        } elsif ($p =~ $n_regex) {
            # noun
            push @os, &get_orient($dbh, $w, $r, '名詞');
        } elsif ($p =~ $a_regex) {
            # adjective
            push @os, &get_orient($dbh, $w, $r, '形容詞');
        } elsif ($p =~ $r_regex) {
            # adverb
            push @os, &get_orient($dbh, $w, $r, '副詞');
        } elsif ($p =~ $av_regex) {
            # auxiliary verb
            push @os, &get_orient($dbh, $w, $r, '助動詞');
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
    my($dbh, $w, $r, $p) = @_;
    my $sth = $dbh->prepare("SELECT orient FROM dictionary WHERE word=? AND reading=? AND pos=?;");
    $sth->execute($w, $r, $p);
    while (my $hr = $sth->fetchrow_arrayref) {
        return $hr->[0] + 0;
    }
    return 0;
}
