package Tweemo::OAuth;
use strict;
use warnings;
use utf8;
use 5.010;
use File::Spec;
use Moo;
use Net::Twitter;
use YAML::Tiny;

sub add_user {
    my $yamlfile = File::Spec->catfile($ENV{'HOME'}, '.tweemo.yml');
    if (-f $yamlfile) {
        my $yaml = YAML::Tiny->read($yamlfile);
        my $config = $yaml->[0];

        my $nt = Net::Twitter->new(
            traits          => ['API::RESTv1_1'],
            consumer_key    => $config->{consumer_key},
            consumer_secret => $config->{consumer_secret},
            ssl             => 1,
        );
        say "open ", $nt->get_authorization_url;
        _open_default_browser($nt->get_authorization_url);
        print "input PIN Number: ";
        my $pin = <STDIN>;
        chomp $pin;

        my($token, $token_secret, $user_id, $screen_name)
            = $nt->request_access_token(verifier => $pin);
        die "'$screen_name' has already registered!\n"
            if _is_dup_account($config, $user_id);
        say "Welcome, ${screen_name}!";

        $config->{users}->{$screen_name} = {
            access_token  => $token,
            access_secret => $token_secret,
            id            => $user_id,
        };
        $yaml->write($yamlfile);
    } else {
        my $config;
        $config->{consumer_key} = 'enH9Qk9yhFiFnE2D86C0i0WbF';
        $config->{consumer_secret}
            = '4yd91BnBlz3j8BghrL7UoRkEZ18slJDVozA1IULXL7D7HNLgo5';

        my $nt = Net::Twitter->new(
            traits          => ['API::RESTv1_1'],
            consumer_key    => $config->{consumer_key},
            consumer_secret => $config->{consumer_secret},
            ssl             => 1,
        );
        say "open ", $nt->get_authorization_url;
        _open_default_browser($nt->get_authorization_url);
        print "input PIN Number: ";
        my $pin = <STDIN>;
        chomp $pin;

        my($token, $token_secret, $user_id, $screen_name)
            = $nt->request_access_token(verifier => $pin);
        say "Welcome, ${screen_name}!";

        $config->{default_user} = $screen_name;
        $config->{users}->{$screen_name} = {
            access_token  => $token,
            access_secret => $token_secret,
            id            => $user_id,
        };
        my $yaml = YAML::Tiny->new($config);
        $yaml->write($yamlfile);
        chmod 0600, $yamlfile or die "cannot change permission '$yamlfile'";
    }
    return 0;
}

sub _is_dup_account {
    my($c, $id) = @_;
    for (keys $c->{users}) {
        return 1 if $c->{users}->{$_}->{id} == $id;
    }
    return 0;
}

sub _open_default_browser {
    my $url = shift;
    my $os  = $^O;

    my $cmd;
    if ($os eq 'darwin') {
        $cmd = "open '$url'";
    } elsif ($os eq 'linux') {
        $cmd = "x-www-browser '$url'";
    } elsif ($os eq 'MSWin32') {
        $cmd = "start '$url'";
    }

    if (defined $cmd) {
        system $cmd;
    } else {
        warn 'cannot locate default browser';
    }
}

1;
