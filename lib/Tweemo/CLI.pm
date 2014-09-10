package Tweemo::CLI;
use strict;
use warnings;
use utf8;
use 5.010;
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

    my($en, $user);
    my $p = Getopt::Long::Parser->new(
        #config => [ 'no_ignore_case', 'pass_through' ],
        config => [ 'no_ignore_case' ],
    );
    $p->getoptionsfromarray(
        \@args,
        'help|?'     => sub { $self->cmd_help;    exit },
        'man'        => sub { $self->cmd_man;     exit },
        'version'    => sub { $self->cmd_version; exit },
        'en|english' => \$en,
        'user=s'     => \$user,
    ) or die "error: Invalid options\n";

    my $cmd = !@args ? 'add_user' :
               $en   ? 'post_en' : 'post_ja';
    my $call = $self->can("cmd_$cmd") or die;
    $self->$call($user, @args);

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
 --en      english tweet
HELP
}

sub cmd_man {
    my $self = shift;
    my $p = $RealBin;
       $p =~ s/(.+)\/.+/$1/;
    system 'perldoc', "$RealBin/../lib/Tweemo.pm";
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

1;
