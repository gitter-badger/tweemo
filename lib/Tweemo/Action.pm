package Tweemo::Action;
use strict;
use warnings;
use utf8;
use 5.010;
use AnyEvent::Twitter::Stream;
use Time::Piece;
use Encode qw(decode);
use File::Spec;
use List::Util qw(sum0);
use Moo;
use Net::Twitter;
use Term::ANSIColor qw(:constants);
use YAML::Tiny;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

sub get_home_timeline {
  my ($self, $user, $count) = @_;
  my $say = undef; # TODO:

  my $nt = _get_net_twitter_obj($user);
  my $ar = defined $count ? $nt->home_timeline({ count => $count })
                          : $nt->home_timeline;
  for my $tweet (reverse @$ar) {
    $self->print($tweet, $say);
  }
}

sub retweet {
  my ($self, $user, $id) = @_;
  die "specified status id you want to retweet the tweet\n" unless defined $id;

  my $nt = _get_net_twitter_obj($user);
  my $s = $nt->retweet($id);
  say 'success: retweeted following tweet';
  say '';
  say "http://twitter.com/$s->{user}{screen_name}/status/$s->{id}";
  $s->{text} = _entities_to_symbols($s->{text});
  say $s->{text};
}

sub favorite {
  my ($self, $user, $id) = @_;
  die "specified status id you want to favorite the tweet\n" unless defined $id;

  my $nt = _get_net_twitter_obj($user);
  my $s = $nt->create_favorite($id);
  say 'success: faved following tweet';
  say '';
  say "http://twitter.com/$s->{user}{screen_name}/status/$s->{id}";
  $s->{text} = _entities_to_symbols($s->{text});
  say $s->{text};
}

sub destroy {
  my ($self, $user, $id) = @_;
  die "specified status id you want to delete the tweet\n" unless defined $id;

  my $nt = _get_net_twitter_obj($user);
  my $s = $nt->destroy_status($id);
  say 'success: destroyed following tweet';
  say '';
  say "http://twitter.com/$s->{user}{screen_name}/status/$s->{id}";
  $s->{text} = _entities_to_symbols($s->{text});
  say $s->{text};
}

sub user_stream {
  my ($self, $user, $say) = @_;

  my $cv = AE::cv;

  my $yamlfile = File::Spec->catfile($ENV{'HOME'}, '.tweemo.yml');
  my $yaml     = YAML::Tiny->read($yamlfile);
  my $config   = $yaml->[0];

  my $du = defined $user ? $user : $config->{default_user};
  my $listener = AnyEvent::Twitter::Stream->new(
    consumer_key    => $config->{consumer_key},
    consumer_secret => $config->{consumer_secret},
    token           => $config->{users}->{$du}->{access_token},
    token_secret    => $config->{users}->{$du}->{access_secret},
    method          => 'userstream',
    on_tweet        => sub {
      my $tweet = shift;
      return unless defined $tweet->{user}{screen_name};
      $self->print($tweet, $say);
    },
    on_error        => sub {
      my $error = shift;
      die "stream error: $error";
    },
  );
  $cv->recv;
}

sub get_user_timeline {
  my ($self, $user, $user_screen_name) = @_;
  $user_screen_name =~ s/^@//;
  my $say = undef; # TODO:

  my $nt = _get_net_twitter_obj($user);
  my $ar = $nt->user_timeline({screen_name => $user_screen_name});
  for my $tweet (reverse @$ar) {
    $self->print($tweet, $say);
  }
}

sub print {
  my ($self, $tweet, $say) = @_;
  my $ca  = $tweet->{created_at};
  my $tp  = localtime Time::Piece->strptime($ca, "%a %b %d %T %z %Y")->epoch;
  my $un  = $tweet->{user}{name};
  my $us  = $tweet->{user}{screen_name};
  speech('ja', $us) if defined $say;
  my $url = "http://twitter.com/$tweet->{user}{screen_name}/status/$tweet->{id}";
  (my $src = $tweet->{source}) =~ s|<a href="(.+)" rel=".+">(.+)</a>|$2 $1|;
  print $tp->strftime('[%m/%d '), $tp->wdayname, $tp->strftime('] (%T) ');
  _print_color_bold_unsco("\@$us");
  print ' ';
  print BOLD, $un, RESET;
  say " $url";
  for (split(/\n/, $tweet->{text})) {
    my @ss = split / /;
    my $i = 0;
    for (@ss) {
      $_ = _entities_to_symbols($_);
      speech('ja', $_) if defined $say;
      if (/^(.*)(@[a-zA-Z0-9_]+)(.*)$/) {
        print $1;
        _print_color_bold_unsco($2);
        print $3;
      } elsif (/^(#.+)$/) {
        print UNDERSCORE, BRIGHT_WHITE, $_, RESET;
      } else {
        print;
      }
      $i++;
      print ' ' if $i != @ss;
    }
    say '';
  }
  say ": $src";
}

sub speech {
  my ($lang, $text) = @_;
  $text =~ s/s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+//g;
  $text =~ s/\"/\\"/g;
  `mplayer -user-agent Mozilla "http://translate.google.com/translate_tts?ie=UTF-8&tl=$lang&q=\$(echo "$text" |sed 's/ /\+/g')" >/dev/null 2>&1`;
}

sub _entities_to_symbols {
  my ($l) = @_;
  $l =~ s/\&gt;/>/g;
  $l =~ s/\&lt;/</g;
  $l =~ s/\&amp;/&/g;
  return $l;
}

sub _print_color_bold_unsco {
  my ($s) = @_;
  my $n = sum0 map { ord } split //, $s;

  # can't use array as color variables
  my @colors = qw(BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN);
  my $n_colors = @colors;
  my $color = @colors[$n % $n_colors];
  if ($color eq $colors[0]) {
    print UNDERSCORE, BOLD, BRIGHT_RED, $s, RESET;
  } elsif ($color eq $colors[1]) {
    print UNDERSCORE, BOLD, BRIGHT_GREEN, $s, RESET;
  } elsif ($color eq $colors[2]) {
    print UNDERSCORE, BOLD, BRIGHT_YELLOW, $s, RESET;
  } elsif ($color eq $colors[3]) {
    print UNDERSCORE, BOLD, BRIGHT_BLUE, $s, RESET;
  } elsif ($color eq $colors[4]) {
    print UNDERSCORE, BOLD, BRIGHT_MAGENTA, $s, RESET;
  } elsif ($color eq $colors[5]) {
    print UNDERSCORE, BOLD, BRIGHT_CYAN, $s, RESET;
  }
}

sub post {
  my ($self, $user, $id, $tweet) = @_;

  die "error: no args\n" unless defined $tweet;
  $tweet = decode('UTF-8', $tweet);

  my $nt = _get_net_twitter_obj($user);
  my @ss = defined $id ? $nt->update($tweet, { in_reply_to_status_id => $id })
                       : $nt->update($tweet);
  for my $s (@ss) {
    say "http://twitter.com/$s->{user}{screen_name}/status/$s->{id}";
    $s->{text} = _entities_to_symbols($s->{text});
    say $s->{text};
  }
}

sub post_with_media {
  my ($self, $user, $id, $img, $tweet) = @_;

  $tweet = defined $tweet ? decode('UTF-8', $tweet) : '';

  my $nt = _get_net_twitter_obj($user);
  my @ss = defined $id ? $nt->update_with_media($tweet, [ $img ], { in_reply_to_status_id => $id })
                       : $nt->update_with_media($tweet, [ $img ]);
  for my $s (@ss) {
    say "http://twitter.com/$s->{user}{screen_name}/status/$s->{id}";
    $s->{text} = _entities_to_symbols($s->{text});
    say $s->{text};
  }
}

sub _get_net_twitter_obj {
  my ($user) = @_;

  my $yamlfile = File::Spec->catfile($ENV{'HOME'}, '.tweemo.yml');
  my $yaml = YAML::Tiny->read($yamlfile);
  my $config = $yaml->[0];
  my $du = defined $user ? $user : $config->{default_user};
  return Net::Twitter->new(
    traits              => ['API::RESTv1_1'],
    consumer_key        => $config->{consumer_key},
    consumer_secret     => $config->{consumer_secret},
    access_token        => $config->{users}->{$du}->{access_token},
    access_token_secret => $config->{users}->{$du}->{access_secret},
    ssl                 => 1,
  );
}

1;
