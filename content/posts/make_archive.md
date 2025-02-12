---
title: "shutil.make_archive()が止まらない"
date: 2025-02-12T07:36:50+09:00
tags: [Linux, Python]
draft: false
---

## 事の発端
最近、自分の作った画像解析ソフトウェアを[Streamlit](https://streamlit.io/)でWebアプリケーション化して、研究所のプログラミングに明るくないメンバーに使ってもらっています。Streamlitは（簡単なものなら）かなり簡単に作れるため、プロトタイピングに大変便利ですね！しかし、今日ユーザーから、いつまで経っても処理が終わらない、という報告を受けました。ログを見ると、`shutil.make_archive()`が`No space left on device`とだけ言い残して死んでいます。あれ、ホストしてるマシンはSSDのスペースまだかなり余っていたはずだけど、と思って`df`コマンドを叩いてみると、`/`以下の使用率が100%近くなっていました。

## 何故か
**A: `shutil.make_archive('test/out', 'zip', root_dir='test')`のように、アーカイブ対象のディレクトリ内でZIPファイルを作ったせいで、再帰的にZIPファイルが巨大化してしまった。**

Streamlitを使ったウェブアプリでは、解析結果は`tempfile.TemporaryDirectory()`で作成した一時ディレクトリ内に保存し、それを最後にzipファイルにまとめてダウンロードする仕組みにしています。ここで、うっかり上記のように、`root_dir`内にzipファイルを作ることで、デバイスの容量を圧迫してプログラムが死ぬまでzipファイルが膨れ上がる現象が生じてしまったようです。

ちなみに、Unixのzipコマンドで同様の事（`zip -r test/out.zip test`）を行っても、`test/`内に`out.zip`が常識的なファイルサイズで作成されます。今回の一件はかなりしょぼいミスが原因（なぜテストで気が付かなかったのか？）でしたが、その代償が大きすぎるというか、[zip爆弾](https://ja.wikipedia.org/wiki/%E9%AB%98%E5%9C%A7%E7%B8%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E7%88%86%E5%BC%BE)のように何らかの脆弱性にもつながりそうだと思いました。

## 再現コード
```
.
├── test
│   └── large_image.png
└── test.py

```
```
❯ python -V
Python 3.10.14                                             
```

`large_image.png`には、zipファイルの膨張が実感できるように、それなりに大きいファイルを入れておきます。

```python
# test.py
import shutil
shutil.make_archive("test/test", "zip", "test")
```

```
❯ python test.py
```

以下のように、順調に（？）ファイルサイズが大きくなっていくのがわかります。
```
❯ du
142704	./test
142708	.
❯ du
326996	./test
327000	.
❯ du
559856	./test
559860	.
❯ du
950052	./test
950056	.
```