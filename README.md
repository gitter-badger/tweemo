tweemo
====

つぶやく -> 平均感情値が出る -> 楽しい

## Description

* 感情は品詞（動詞，名詞，形容詞，副詞，助動詞）に -1 から 1 までの値を割り振り，その平均を出す（辞書にない場合は 0 とする）．

* 使わせて頂いた辞書 [Semantic Orientations of Words](http://www.lr.pi.titech.ac.jp/~takamura/pndic_en.html)

## Requirement

* [MeCab](https://code.google.com/p/mecab/)（日本語つぶやきに必要）
* [TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/)（英語つぶやきに必要）
* perl modules ( AnyEvent::Twitter::Stream, DBD::SQLite, DBI, File::Which, Moo, Net::Twitter, Statistics::Lite, YAML::Tiny )

## Usage

```
# アカウント登録，追加
tweemo --add

# デフォルトアカウントでつぶやく
tweemo '今日も一日がんばるぞい！'

# 登録済みアカウント mult_acc で実行
tweemo --user mult_acc 'もうこんな仕事辞めたいぞい…'

# http://twitter.com/foo/status/012345678901234567 のつぶやきに返信
tweemo '@foo 今夜はクレープみたいな夢に包まれますように' --id 012345678901234567

# http://twitter.com/foo/status/012345678901234567 のつぶやきをRT
tweemo --rt --id 012345678901234567

# http://twitter.com/foo/status/012345678901234567 のつぶやきをFAV
tweemo --fav --id 012345678901234567

# 自身のつぶやき http://twitter.com/my_acc/status/987654321098765432 を削除
tweemo --del --id 987654321098765432

# tweet in English
tweemo --en "Oh god, it's a bikeshed discussion."

# TLの最新20件を取得
tweemo --tl
# TL最新100件を取得(最大200件)
tweemo --tl -n 100

# User streams
# 引数，オプションなしは --st と同じ
tweemo --st
tweemo
# 音声付き User streams
tweemo --st --say
tweemo --say

# @foo のつぶやき最新20件を取得
tweemo @foo

# 画像upload(jpg, png, gif対応)
tweemo '穏やかじゃない！' --img image.jpg
```

## Install

```
# Arch
yaourt -S mecab mecab-ipadic-utf8
# Debian
sudo apt-get install mecab mecab-ipadic-utf8
# If you use others, install those from package manager or source.

cpanm AnyEvent::Twitter::Stream DBD::SQLite DBI File::Which Moo Net::Twitter Statistics::Lite YAML::Tiny

git clone git@github.com:suruga/tweemo.git
```
英語つぶやきをしたい場合のみ，TreeTaggerをインストール後，PATHにtreetagger/{bin,cmd}を追加しておく．

* --add オプションで実行するとアカウント登録を行う．
    * Twitter認証ページへ促され，そこで認証．端末へ戻りPINを入力すれば ~/.tweemo.yml が更新される．
* 複数アカウント対応．デフォルトは最初に登録したアカウント．
    * デフォルトアカウントは .tweemo.yml の default_user: のユーザ名を直接書き換えることで変更可能．
* --say オプションはGoogle翻訳の日本語でしゃべる．利用するには mplayer へPATHが通っている必要あり．

## See also

[tw](https://github.com/shokai/tw)

## Licence

"THE COFFEE-WARE LICENSE" (Revision 15):
<suruga179f@gmail.com> wrote this files.  As long as you retain this notice
you can do whatever you want with this stuff. If we meet some day, and you
think this stuff is worth it, you can buy me a coffee in return.
