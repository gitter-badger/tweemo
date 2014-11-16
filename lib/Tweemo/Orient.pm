package Tweemo::Orient;
use strict;
use warnings;
use utf8;
use 5.010;
use DBI;
use DBD::SQLite;
use Encode qw(decode);
use File::Spec;
use FindBin qw($RealBin);
use Moo;
use Statistics::Lite qw(mean);

sub concat_orient_en {
  my ($self, $msg) = @_;

  die "error: no message\n" unless defined $msg;
  my $D = "\t"; # delimiter
  my $treetagger = 'tree-tagger-english';

  # Tag Set https://courses.washington.edu/hypertxt/csar-v02/penntable.html
  my $v_regex = qr/^(VB|VBD|VBG|VBN|VBZ|VBP|VD|VDD|VDG|VHN|VHZ|VHP|VV|VVD|VVG|VVN|VVP|VVZ)$/;
  my $n_regex = qr/^(NN|NNS|NP|NPS|PP)$/;
  my $a_regex = qr/^(JJ|JJR|JJS)$/;
  my $r_regex = qr/^(RB|RBR|RBS)$/;

  my $db = File::Spec->catfile($RealBin, File::Spec->updir, 'db', 'pn_en.dic.db');
  my $dbh = DBI->connect("dbi:SQLite:dbname=$db", undef, undef,
                         {AutoCommit => 0, RaiseError => 1 });
  $dbh->{sqlite_unicode} = 1;

  (my $s = $msg) =~ s/"/\\"/g;
  my @res = split(/\n/, `echo "$s" |$treetagger 2>/dev/null`);
  my @os = ();
  for (@res) {
    if (/^.+$D(.+)$D(.+)$/) {
      my ($p, $l) = ($1, $2);
      $l = "\L$l";    # dictionary containts only lowercase
      if ($p =~ $v_regex) {        # verb
        push @os, _get_orient_en($dbh, $l, 'v');
      } elsif ($p =~ $n_regex) {   # noun
        push @os, _get_orient_en($dbh, $l, 'n');
      } elsif ($p =~ $a_regex) {   # adjective
        push @os, _get_orient_en($dbh, $l, 'a');
      } elsif ($p =~ $r_regex) {   # adverb
        push @os, _get_orient_en($dbh, $l, 'r');
      }
    }
  }

  $dbh->commit;
  $dbh->disconnect;

  my $val = @os ? int(mean(@os) * (10**4)) / (10**4) : 0;
  $msg .= " ($val)";

  return $msg;
}

sub _get_orient_en {
  my ($dbh, $w, $p) = @_;
  my $sth = $dbh->prepare("SELECT orient FROM dictionary WHERE word=? AND pos=?;");
  $sth->execute($w, $p);
  while (my $hr = $sth->fetchrow_arrayref) {
    return $hr->[0] + 0;
  }
  return 0;
}

sub concat_orient_ja {
  my ($self, $msg) = @_;

  die "error: no message" unless defined $msg;

  my ($v_regex, $n_regex, $a_regex, $r_regex, $av_regex)
    = (qr/^動詞$/, qr/^名詞$/, qr/^形容詞$/, qr/^副詞$/, qr/^助動詞$/);

  my $db = File::Spec->catfile($RealBin, File::Spec->updir, 'db', 'pn_ja.dic.db');
  my $dbh = DBI->connect("dbi:SQLite:dbname=$db", undef, undef,
                         {AutoCommit => 0, RaiseError => 1 });
  $dbh->{sqlite_unicode} = 1;

  (my $s = $msg) =~ s/"/\\"/g;
  my @res = split(/\n/, `echo "$s" |mecab`);
  my @os = ();
  for (@res) {
    if (/^.+\t(.+),.+,.+,.+,.+,.+,(.+),(.+),.+$/) {
      my ($p, $w, $r) = ($1, $2, $3);
      $p = decode('UTF-8', $p);
      $w = decode('UTF-8', $w);
      $r = decode('UTF-8', $r);
      if ($p =~ $v_regex) {         # verb
        push @os, _get_orient_ja($dbh, $w, $r, '動詞');
      } elsif ($p =~ $n_regex) {    # noun
        push @os, _get_orient_ja($dbh, $w, $r, '名詞');
      } elsif ($p =~ $a_regex) {    # adjective
        push @os, _get_orient_ja($dbh, $w, $r, '形容詞');
      } elsif ($p =~ $r_regex) {    # adverb
        push @os, _get_orient_ja($dbh, $w, $r, '副詞');
      } elsif ($p =~ $av_regex) {   # auxiliary verb
        push @os, _get_orient_ja($dbh, $w, $r, '助動詞');
      }
    }
  }

  $dbh->commit;
  $dbh->disconnect;

  my $val = @os ? int(mean(@os) * (10**4)) / (10**4) : 0;
  $msg .= " ($val)";

  return $msg;
}

sub _get_orient_ja {
  my ($dbh, $w, $r, $p) = @_;
  my $sth = $dbh->prepare("SELECT orient FROM dictionary WHERE word=? AND reading=? AND pos=?;");
  $sth->execute($w, $r, $p);
  while (my $hr = $sth->fetchrow_arrayref) {
    return $hr->[0] + 0;
  }
  return 0;
}

1;
