tweemo
====

つぶやく -> 平均感情値が出る -> 楽しい
           
## Description

* 感情は品詞（動詞，名詞，形容詞，副詞，助動詞）に -1 から 1 までの値を割り振り，その平均を出す（辞書にない場合は 0 とする）．

* 使わせて頂いた辞書 [Semantic Orientations of Words](http://www.lr.pi.titech.ac.jp/~takamura/pndic_en.html)

## Requirement

* [MeCab](https://code.google.com/p/mecab/)（日本語つぶやきに必要）
* [TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/)（英語つぶやきに必要）
* perl modules ( AnyEvent::Twitter::Stream, DBD::SQLite, DBI, Net::Twitter, Statistics::Lite, YAML::Tiny )
      
## Usage

```
# アカウント登録，追加
$ tweemo --add
# デフォルトアカウントでつぶやく
$ tweemo '今日も一日がんばるぞい！'
# 登録済みアカウント user2 で実行
$ tweemo --user=user2 'もうこんな仕事辞めたいぞい…'
# tweet in English
$ tweemo --en "Oh god, it's a bikeshed discussion."
# TLの最新20件を取得
$ tweemo --tl
# User streams
# 引数，オプションなしは --st と同じ
$ tweemo --st
```

## Install

```
# For Mac OS X.
# If you use Linux, install those from package manager or source.
$ brew install mecab mecab-ipadic

$ cpanm DBI DBD::SQLite Net::Twitter Statistics::Lite YAML::Tiny
$ git clone git@github.com:suruga/tweemo.git
```                              
英語つぶやきをしたい場合のみ，TreeTaggerをインストール後，PATHにtreetagger/{bin,cmd}を追加しておく．

* --add オプションで実行するとアカウント登録を行う．
    * Twitter認証ページへ促され，そこで認証．端末へ戻りPINを入力すれば ~/.tweemo.yml が更新される．
* 複数アカウント対応．デフォルトは最初に登録したアカウント．
    * デフォルトアカウントは .tweemo.yml の default_user: のユーザ名を直接書き換えることで変更可能．

## See also

[tw](https://github.com/shokai/tw)

## Licence

"THE COFFEE-WARE LICENSE" (Revision 15):  
<suruga179f@gmail.com> wrote this files.  As long as you retain this notice  
you can do whatever you want with this stuff. If we meet some day, and you  
think this stuff is worth it, you can buy me a coffee in return.
