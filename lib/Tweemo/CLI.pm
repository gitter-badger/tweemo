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

sub run {
    my($self, @args) = @_;

    my($add, $en, $img, $st, $tl, $user);
    my $p = Getopt::Long::Parser->new(
        config => [ 'no_ignore_case' ],
    );
    $p->getoptionsfromarray(
        \@args,
        'help|?'      => sub { $self->cmd_help;    exit },
        'man'         => sub { $self->cmd_man;     exit },
        'version'     => sub { $self->cmd_version; exit },
        'add'         => \$add,
        'st|stream'   => \$st,
        'tl|timeline' => \$tl,
        'img=s'       => \$img,
        'en|english'  => \$en,
        'user=s'      => \$user,
    ) or die "error: Invalid options\n";

    my $cmd;
    if ($add) {
        $cmd = 'add_user';
    } elsif ($tl) {
        $cmd = 'get_home_timeline';
    } elsif ($img) {
        $cmd = 'post_with_media';
    } elsif ($st || !@args) {
        $cmd = 'user_stream';
    } elsif (_is_user_screen_name(@args)) {
        $cmd = 'get_user_timeline';
    } else {
        $cmd = $en ? 'post_en' : 'post_ja';
    }

    my $call = $self->can("cmd_$cmd")
        or die "error: Invalid option commands";
    if ($cmd eq 'post_with_media') {
        $self->cmd_post_with_media($user, $img, @args);
    } else {
        $self->$call($user, @args);
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

sub cmd_post_en {
    my($self, @args) = @_;
    my $user = shift @args;

    my $tweet = Tweemo::Orient->concat_orient_en(@args);
    Tweemo::Action->post($user, $tweet);
}

sub cmd_post_ja {
    my($self, @args) = @_;
    my $user = shift @args;

    my $tweet = Tweemo::Orient->concat_orient_ja(@args);
    Tweemo::Action->post($user, $tweet);
}

sub cmd_post_with_media {
    my($self, @args) = @_;
    my $user = shift @args;
    my $img  = shift @args;
    my $text = shift @args;

    $text = defined $text ? Tweemo::Orient->concat_orient_ja($text) : '';
    Tweemo::Action->post_with_media($user, $img, $text);
}

sub _is_user_screen_name {
    my @as = @_;
    for (@as) {
        return 1 if /^@[a-zA-Z0-9_]+$/;
    }
    return 0;
}

1;
