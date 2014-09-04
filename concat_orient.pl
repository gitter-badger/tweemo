#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use DBI;
use DBD::SQLite;
use Encode;
use FindBin qw($Bin);
use Getopt::Long;
use Statistics::Lite 'mean';

sub usage {
    print <<EOM;
usage: $0 'message'
EOM
    exit 0;
}

my $v_regex = qr/^動詞$/;
my $n_regex = qr/^名詞$/;
my $a_regex = qr/^形容詞$/;
my $r_regex = qr/^副詞$/;
my $av_regex = qr/^助動詞$/;
#my $s_regex = qr/^SENT$/;

my $MSG = $ARGV[0];
my $DIC_DB = "$Bin/db/pn_ja.dic.db";
my $HELP;

GetOptions(
    'help' => \$HELP,
);

&usage() if $HELP;

my $dic_dbh = DBI->connect("dbi:SQLite:dbname=$DIC_DB", undef, undef, 
    {AutoCommit => 0, RaiseError => 1 });
$dic_dbh->{sqlite_unicode} = 1;

my $s = $MSG;
$s =~ s/"/\\"/g;
my @res = split(/\n/, `echo "$s" |mecab`);
my @os = ();
for (@res) {
    if (/^(.+)\t(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)$/) {
        my ($p, $w, $r) = ($2, $8, $9);
        $p = decode('UTF-8', $p);
        $w = decode('UTF-8', $w);
        $r = decode('UTF-8', $r);
        if ($p =~ $v_regex) {
            # verb
            push @os, &get_orient($dic_dbh, $w, $r, '動詞');
        } elsif ($p =~ $n_regex) {
            # noun
            push @os, &get_orient($dic_dbh, $w, $r, '名詞');
        } elsif ($p =~ $a_regex) {
            # adjective
            push @os, &get_orient($dic_dbh, $w, $r, '形容詞');
        } elsif ($p =~ $r_regex) {
            # adverb
            push @os, &get_orient($dic_dbh, $w, $r, '副詞');
        } elsif ($p =~ $av_regex) {
            # auxiliary verb
            push @os, &get_orient($dic_dbh, $w, $r, '助動詞');
        }
    }
}

$dic_dbh->commit;
$dic_dbh->disconnect;

my $val = @os ? int(mean(@os) * (10**4)) / (10**4) : 0;
$MSG .= " ($val)";
print $MSG;

exit 0;

sub get_orient {
    my ($dbh, $w, $r, $p) = @_;
    my $sth = $dbh->prepare("SELECT orient FROM dictionary WHERE word=? AND reading=? AND pos=?;");
    $sth->execute($w, $r, $p);
    while (my $hr = $sth->fetchrow_arrayref) {
        return $hr->[0] + 0;
    }
    return 0;
}
