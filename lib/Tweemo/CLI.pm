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

    my($en, $img, $st, $tl, $user);
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
        'tl|timeline' => \$tl,
        'img=s'       => \$img,
        'en|english'  => \$en,
        'user=s'      => \$user,
    ) or die "error: Invalid options\n";

    if ($tl) {
        $self->cmd_get_home_timeline($user);
    } elsif ($img) {
        $self->cmd_post_with_media($user, $en, $img, @args);
    } elsif ($st || !@args) {
        $self->cmd_user_stream($user);
    } elsif (_is_user_screen_name(@args)) {
        $self->cmd_get_user_timeline($user, @args);
    } else {
        $self->cmd_post($user, $en, @args);
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
 --user    set user
 --add     add user
 --en      english tweet
 --tl      show the 20 most recent tweets
 --img     upload image (jpg, png, gif)

tweemo \@user  # show the 20 most recent \@user's tweets
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
    my $user = shift @args;

    Tweemo::Action->get_home_timeline($user);
}

sub cmd_user_stream {
    my($self, @args) = @_;
    my $user = shift @args;

    Tweemo::Action->user_stream($user);
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
    my $en   = shift @args;

    my $tweet = $en ? Tweemo::Orient->concat_orient_en(@args)
                    : Tweemo::Orient->concat_orient_ja(@args);
    Tweemo::Action->post($user, $tweet);
}

sub cmd_post_with_media {
    my($self, @args) = @_;
    my $user = shift @args;
    my $en   = shift @args;
    my $img  = shift @args;

    my $tweet = !@args ? '' :
                $en ? Tweemo::Orient->concat_orient_en(@args)
                    : Tweemo::Orient->concat_orient_ja(@args);
    Tweemo::Action->post_with_media($user, $img, $tweet);
}

sub _is_user_screen_name {
    my @as = @_;
    for (@as) {
        return 1 if /^@[a-zA-Z0-9_]+$/;
    }
    return 0;
}

1;
