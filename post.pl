#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Encode qw(decode);
use Getopt::Long;
use Net::Twitter;
use YAML::Tiny;

sub usage {
    print <<EOM;
usage: $0              'tweet message'
       $0 --user=user2 'tweet message'
EOM
    exit;
}

my $HELP;
my $USER;

GetOptions(
    'help'   => \$HELP,
    'user=s' => \$USER,
);

&usage() if $HELP;

my $yamlfile = "$ENV{'HOME'}/.tweemo.yml";
my $yaml = YAML::Tiny->read($yamlfile);
my $config = $yaml->[0];

my $du = defined $USER ? $USER : $config->{default_user};
my $nt = Net::Twitter->new(
    traits => ['API::RESTv1_1'],
    consumer_key        => $config->{consumer_key},
    consumer_secret     => $config->{consumer_secret},
    access_token        => $config->{users}->{$du}->{access_token},
    access_token_secret => $config->{users}->{$du}->{access_secret},
    ssl => 1,
);

my $tweet = $ARGV[0];
$tweet = decode('UTF-8', $tweet);
$nt->update($tweet);
