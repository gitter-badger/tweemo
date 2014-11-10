package Tweemo::CLI;
use strict;
use warnings;
use utf8;
use 5.010;
use File::Spec;
use FindBin qw($RealBin $RealScript);
use Getopt::Long;
use Moo;

use Tweemo;
use Tweemo::Action;
use Tweemo::OAuth;
use Tweemo::Orient;

use constant { SUCCESS => 0, INFO => 1, WARN => 2, ERROR => 3 };

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

sub run {
  my($self, @args) = @_;

  my($del, $en, $fav, $id, $img, $n, $rt, $say, $st, $tl, $user);
  my $p = Getopt::Long::Parser->new(
    config => [ 'no_ignore_case' ],
  );
  $p->getoptionsfromarray(
    \@args,
    'help|?'      => sub { $self->cmd_help;     exit },
    'man'         => sub { $self->cmd_man;      exit },
    'version'     => sub { $self->cmd_version;  exit },
    'add'         => sub { $self->cmd_add_user; exit },
    'st|stream'   => \$st,
    'say|speech'  => \$say,
    'tl|timeline' => \$tl,
    'n|num=s'     => \$n,
    'rt|retweet'  => \$rt,
    'fav'         => \$fav,
    'del'         => \$del,
    'id=s'        => \$id,
    'img=s'       => \$img,
    'en|english'  => \$en,
    'user=s'      => \$user,
  ) or die "error: Invalid options\n";

  if ($tl) {
    $self->cmd_get_home_timeline($user, $n);
  } elsif ($rt) {
    $self->cmd_retweet($user, $id);
  } elsif ($fav) {
    $self->cmd_favorite($user, $id);
  } elsif ($del) {
    $self->cmd_destroy($user, $id);
  } elsif ($img) {
    $self->cmd_post_with_media($user, $id, $en, $img, @args);
  } elsif ($st || !@args) {
    $self->cmd_user_stream($user, $say);
  } elsif (_is_user_screen_name(@args)) {
    $self->cmd_get_user_timeline($user, @args);
  } else {
    $self->cmd_post($user, $id, $en, @args);
  }

  return 0;
}

sub cmd_help {
  my $self = shift;
  $self->cmd_usage;
}

sub cmd_usage {
  my $self = shift;
  $self->print(<<HELP);
usage: $RealScript 'tweet message'

options:
 --user      set user
 --add       add user
 --id        reply to the tweet
 --st        user streams (default action)
 --say       say User streams by Google translate
 --rt        retweet the tweet   (--id required)
 --fav       favorites the tweet (--id required)
 --del       destroy my tweet    (--id required)
 --en        english tweet
 --tl        show the 20 most recent tweets
 --tl -n K   show the K(<= 200) most recent tweets
 --img       upload image (jpg, png, gif)

tweemo \@foo                     # show the 20 most recent \@foo's tweets
tweemo '\@foo LGTM' --id 12345   # reply to the tweet (http://twitter.com/foo/12345)
HELP
}

sub cmd_man {
  my $self = shift;
  (my $p = $RealBin) =~ s/(.+)\/.+/$1/;
  my $doc = File::Spec->catfile($RealBin, File::Spec->updir(), 'lib',
    'Tweemo.pm');
  system 'perldoc', $doc;
  exit;
}

sub print {
  my($self, $msg, $type) = @_;
  my $fh = $type && $type >= WARN ? *STDERR : *STDOUT;
  print {$fh} $msg;
}

sub cmd_version {
  my $self = shift;
  $self->print("$RealScript $Tweemo::VERSION\n");
}

sub cmd_get_home_timeline {
  my($self, @args) = @_;
  my $user  = shift @args;
  my $count = shift @args;

  Tweemo::Action->get_home_timeline($user, $count);
}

sub cmd_retweet {
  my($self, @args) = @_;
  my $user = shift @args;
  my $id   = shift @args;

  Tweemo::Action->retweet($user, $id);
}

sub cmd_favorite {
  my($self, @args) = @_;
  my $user = shift @args;
  my $id   = shift @args;

  Tweemo::Action->favorite($user, $id);
}

sub cmd_destroy {
  my($self, @args) = @_;
  my $user = shift @args;
  my $id   = shift @args;

  Tweemo::Action->destroy($user, $id);
}

sub cmd_user_stream {
  my($self, @args) = @_;
  my $user = shift @args;
  my $say  = shift @args;

  Tweemo::Action->user_stream($user, $say);
}

sub cmd_get_user_timeline {
  my($self, @args) = @_;
  Tweemo::Action->get_user_timeline(@args);
}

sub cmd_add_user {
  Tweemo::OAuth->add_user;
}

sub cmd_post {
  my($self, @args) = @_;
  my $user = shift @args;
  my $id   = shift @args;
  my $en   = shift @args;

  my $tweet = $en ? Tweemo::Orient->concat_orient_en(@args)
  : Tweemo::Orient->concat_orient_ja(@args);
  Tweemo::Action->post($user, $id, $tweet);
}

sub cmd_post_with_media {
  my($self, @args) = @_;
  my $user = shift @args;
  my $id   = shift @args;
  my $en   = shift @args;
  my $img  = shift @args;

  my $tweet = !@args ? '' :
  $en ? Tweemo::Orient->concat_orient_en(@args)
  : Tweemo::Orient->concat_orient_ja(@args);
  Tweemo::Action->post_with_media($user, $id, $img, $tweet);
}

sub _is_user_screen_name {
  my @as = @_;
  for (@as) {
    return 1 if /^@[a-zA-Z0-9_]+$/;
  }
  return 0;
}

1;
