tweet-emo
====

つぶやく -> 平均感情値が出る -> 楽しい
           
## Description

* 感情は品詞（動詞，名詞，形容詞，副詞，助動詞）に -1 から 1 までの値を割り振り，その平均を出す（辞書にない場合は 0 とする）．

* 使わせて頂いた辞書 [Semantic Orientations of Words](http://www.lr.pi.titech.ac.jp/~takamura/pndic_en.html)

## Requirement

* [MeCab](https://code.google.com/p/mecab/)
* [TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/)（英語つぶやき時のみ必要）
* perl module ( DBI, DBD::SQLite, Net::Twitter, Statistics::Lite )
      
## Usage

```
# デフォルトアカウント
$ ./tweet-emo '今日も一日がんばるぞい！'
# 登録済みアカウント user2
$ ./tweet-emo --user=user2 'もうこんな仕事辞めたいぞい…'
# Englis tweet
$ ./tweet-emo --en 'Oh god, this is a bikeshed discussion.'
```

## Install

```
$ brew install mecab mecab-ipadic
$ cpanm DBI DBD::SQLite Net::Twitter Statistics::Lite YAML::Tiny
$ git clone git@github.com:suruga/tweet-emo.git
```                              
英語つぶやきをしたい場合のみ，TreeTaggerをインストール後，PATHにtreetagger/{bin,cmd}を追加しておく．

* 引数なしで実行すると，アカウント登録を行う．
    * Twitter認証ページへ促され，そこで認証．端末へ戻りPINを入力すればホームディレクトリ直下の .tweet-emo.yml が更新される．
* 複数アカウント対応．デフォルトは最初に登録したアカウント．
    * デフォルトアカウントは .tweet-emo.yml の default_user: のユーザ名を直接書き換えることで変更可能．

## Reference

[tw](https://github.com/shokai/tw)

## Licence

"THE COFFEE-WARE LICENSE" (Revision 15):  
<suruga179f@gmail.com> wrote this files.  As long as you retain this notice  
you can do whatever you want with this stuff. If we meet some day, and you  
think this stuff is worth it, you can buy me a coffee in return.