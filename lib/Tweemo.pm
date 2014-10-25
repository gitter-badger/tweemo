package Tweemo;
use strict;
use warnings;
use utf8;
use 5.010;
use version; our $VERSION = version->declare("v0.0.01");

1;
__END__

=head1 NAME

tweemo - Perl emotional twitter client

=head1 SYNOPSIS

  > tweemo --add                 # add twitter account
  > tweemo 'text'                # default account's japanese tweet
  > tweemo --user=user2 'text'   # user2 account's tweet
  > tweemo --en 'text'           # english tweet
  > tweemo --tl                  # show the 20 most recent tweets
  > tweemo --st                  # user streams
  > tweemo                       # default action is user streams
  > tweemo @user                 # show the 20 most recent @user's tweets
  > tweemo --img foo.jpg         # upload image (jpg, png, gif)

=head1 DESCRIPTION

tweemo is a command line tool to tweet message.
This calculates the value of emotion of message, using semantic
orientations of words.

=head2 DEPENDENCIES

If you tweet japanese message, you should install Mecab, and if also tweet
english message, install TreeTagger, too.

=head1 AUTHOR

Shunya Kawabata

=head1 COPYRIGHT

Shunya Kawabata 2014-

=head1 LICENSE

"THE COFFEE-WARE LICENSE" (Revision 15):
<suruga179f@gmail.com> wrote this files.  As long as you retain this notice
you can do whatever you want with this stuff. If we meet some day, and you
think this stuff is worth it, you can buy me a coffee in return.

=head1 SEE ALSO

L<tw|https://github.com/shokai/tw>

L<MeCab|https://code.google.com/p/mecab/>

L<TreeTagger|http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/>

=cut
