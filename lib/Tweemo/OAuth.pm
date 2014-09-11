package Tweemo::OAuth;
use strict;
use warnings;
use utf8;
use 5.010;
use Moo;
use Net::Twitter;
use YAML::Tiny;

sub add_user {
    my $yamlfile = "$ENV{'HOME'}/.tweemo.yml";
    if (-f $yamlfile) {
        my $yaml = YAML::Tiny->read($yamlfile);
        my $config = $yaml->[0];

        my $nt = Net::Twitter->new(
            traits => ['API::RESTv1_1'],
            consumer_key    => $config->{consumer_key},
            consumer_secret => $config->{consumer_secret},
            ssl => 1,
        );
        print "open ", $nt->get_authorization_url, "\n";
        print "input PIN Number: ";
        my $pin = <STDIN>;
        chomp $pin;

        my($token, $token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);
        die "'$screen_name' has already registered!\n" if &is_dup_account($config, $user_id);
        print "Welcome, ${screen_name}!\n";

        $config->{users}->{$screen_name} = {
            access_token  => $token,
            access_secret => $token_secret,
            id => $user_id,
        };
        $yaml->write($yamlfile);
    } else {
        my $config;
        $config->{consumer_key}    = 'quundbKr6xsKYiMzimSPn2Qb9';
        $config->{consumer_secret} = 'vRv3uBzoClXT9fn0qpqT3qmaSj0yB1jN2ENj8DcgYC3zR1qUxE';

        my $nt = Net::Twitter->new(
            traits => ['API::RESTv1_1'],
            consumer_key    => $config->{consumer_key},
            consumer_secret => $config->{consumer_secret},
            ssl => 1,
        );
        print "open ", $nt->get_authorization_url, "\n";
        print "input PIN Number: ";
        my $pin = <STDIN>;
        chomp $pin;

        my($token, $token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);
        print "Welcome, ${screen_name}!\n";

        $config->{default_user} = $screen_name;
        $config->{users}->{$screen_name} = {
            access_token  => $token,
            access_secret => $token_secret,
            id => $user_id,
        };
        my $yaml = YAML::Tiny->new($config);
        $yaml->write($yamlfile);
        chmod 0600, $yamlfile || die "cannot change permission '$yamlfile'";
    }
    
    return 0;

    sub is_dup_account {
        my($c, $id) = @_;
        for (keys $c->{users}) {
            return 1 if $c->{users}->{$_}->{id} == $id;
        }
        return 0;
    }
}

1;
