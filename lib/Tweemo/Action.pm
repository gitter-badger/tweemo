package Tweemo::Action;
use strict;
use warnings;
use utf8;
use 5.010;
use Encode qw(decode);
use File::Spec;
use Moo;
use Net::Twitter;
use YAML::Tiny;

sub post {
    my($self, @args) = @_;
    my $user = shift @args;

    my $tweet = shift @args or die "error: no args";
       $tweet = decode('UTF-8', $tweet);

    my $yamlfile = File::Spec->catfile($ENV{'HOME'}, '.tweemo.yml');
    my $yaml = YAML::Tiny->read($yamlfile);
    my $config = $yaml->[0];

    my $du = defined $user ? $user : $config->{default_user};
    my $nt = Net::Twitter->new(
        traits => ['API::RESTv1_1'],
        consumer_key        => $config->{consumer_key},
        consumer_secret     => $config->{consumer_secret},
        access_token        => $config->{users}->{$du}->{access_token},
        access_token_secret => $config->{users}->{$du}->{access_secret},
        ssl => 1,
    );
    $nt->update($tweet);
}

1;
