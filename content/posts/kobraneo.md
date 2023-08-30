# Anycubic KobraNeo の改造
最近、研究で3Dプリンターを使うことが多くなりました。
野外になにか観測機器を設置しようと思うと、その場に合わせた微妙な形の治具を作る必要に迫られることが多々有ります。
これまではアルミ板を加工したりホムセンで売ってる既存の治具を組み合わせて頑張っていたのですが、
3Dプリンターで自由に作れるととても便利です。3DCADも最近はかなり使いやすくなってきたらしく、
それほど勉強しないでもある程度のものは作れます。私はLinuxユーザーなのでクラウドで動いてブラウザ上でいじれる[Onshape](https://www.onshape.com/ja/)
を使っていますが、かなりいい感じです。

研究室には[Prusa i3 MK3S+](https://www.prusa3d.com/product/original-prusa-i3-mk3s-3d-printer-3/)があるので基本的にはこれを使って印刷をしていました。
しかし、なにかの拍子に印刷がうまくいかなくなるタイミングというのが来ます。設定をいろいろ試し、パーツの位置を調節しても、うまく行かない。やがてもう今日は帰れないんじゃないか、という不安に襲われ、もう自宅に置いて寝食をともにしたほうがいいのではないかという気持ちになってきます。
そうこうしているうちに、[Anycubic KobraNeo](https://www.amazon.co.jp/ANYCUBIC-Anycubic-vyper-3D%E3%83%97%E3%83%AA%E3%83%B3%E3%82%BF%E3%83%BC/dp/B0BC1LXQNT?th=1)という3Dプリンターを購入しました。購入時価格で3万円弱でしたが、ダイレクトエクストルーダでオートベッドレベリングまでついてくるのはお得に感じました。（今思えば[Sovol SV06](https://www.amazon.co.jp/Sovol-300x300x340mm%E5%8D%B0%E5%88%B7%E3%82%B5%E3%82%A4%E3%82%BA-PEI%E3%81%B0%E3%81%AD%E9%8B%BC%E7%A3%81%E6%B0%97%E3%83%97%E3%83%A9%E3%83%83%E3%83%88%E3%83%95%E3%82%A9%E3%83%BC%E3%83%A0-4-3inch%E3%82%BF%E3%83%83%E3%83%81%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3-32%E3%83%93%E3%83%83%E3%83%88%E3%82%B5%E3%82%A4%E3%83%AC%E3%83%B3%E3%83%88%E3%83%9C%E3%83%BC%E3%83%89/dp/B0BJV3WB2J/ref=d_pd_vtp_sccl_3_6/358-0704816-9539537?pd_rd_w=b2NTP&content-id=amzn1.sym.445d7698-fcdd-4b7c-94ce-1e473f27a23f&pf_rd_p=445d7698-fcdd-4b7c-94ce-1e473f27a23f&pf_rd_r=VN85ER5655M9PH6D3E1S&pd_rd_wg=Yb9RB&pd_rd_r=8fb71ef6-e681-49bd-962d-551dbab91b74&pd_rd_i=B0C77PLFRJ&th=1)とかのほうが良かったと反省しています。デュアルZ軸とリニアガイドレールは結構ほしいです。）

以下はKobraNeoを買ってから半年ほどの間に行った改造のメモです。

## デュアルZ軸
KobraNeoにはZ軸のリードスクリューが片方にしかついていません。これは（特にZホッピングなどの急激な上下運動をする際に）X軸の水平性を保つ上であまり良くありません。
[PrintablesでデュアルZ軸へ改造するためのパーツを見つけた](https://www.printables.com/model/364889-anycubic-kobra-neogo-dual-z-mod)ので、試してみることにしました。  

### プリントパーツ
https://www.printables.com/model/364889-anycubic-kobra-neogo-dual-z-mod
上記リンクのSTLファイルをASAで印刷しました。

### その他部品
- [ステッピングモーター](https://www.amazon.co.jp/gp/product/B06XRFGTR4/ref=ppx_yo_dt_b_asin_title_o06_s00?ie=UTF8&th=1)  
ボディ幅が34 mmのNema17ステッピングモータを使います。  
- [リードスクリュー](https://www.amazon.co.jp/gp/product/B09BZBZ7BR/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&th=1)  
> 8 mm dia. * 2 mm pitch * 8 mm lead acme lead screw (I think the one you need for full Z height is 350 mm long. Mine looks short because I just used one that I had from an old printer.)`  
と書いてるので、これに合ったものを選びます。切り口の数が4個あるもの（Tr8x8）を選ぶ必要があるので要注意です。
- [モータシャフトカプラー](https://www.amazon.co.jp/Saipor-%E3%83%A2%E3%83%BC%E3%82%BF%E3%83%BC%E3%82%B7%E3%83%A3%E3%83%95%E3%83%88%E3%82%AB%E3%83%97%E3%83%A9-%E3%82%AB%E3%83%97%E3%83%A9%E3%83%BC%E3%82%AB%E3%83%83%E3%83%97%E3%83%AA%E3%83%B3%E3%82%B0-17%E3%82%B9%E3%83%86%E3%83%83%E3%83%94%E3%83%B3%E3%82%B0%E3%83%A2%E3%83%BC%E3%82%BF%E3%83%BC%E3%81%AB%E5%AF%BE%E5%BF%9C-%E7%9B%B4%E5%BE%8419mm%E3%80%81%E9%95%B7%E3%81%9525mm/dp/B07ZMYSYLH/ref=d_pd_sbs_sccl_3_3/358-0704816-9539537?pd_rd_w=6PQiU&content-id=amzn1.sym.4e3fe7e8-7339-4e4f-87be-631ff86daf6e&pf_rd_p=4e3fe7e8-7339-4e4f-87be-631ff86daf6e&pf_rd_r=0RBN2FMENZ5RA4SN52WZ&pd_rd_wg=WO8bv&pd_rd_r=01765439-9cfa-40f2-97ca-8ff26627d29c&pd_rd_i=B07ZMYSYLH&psc=1)  
- ネジ  
>2 - M5*40 bolts (you can get away with M5*35; that was what i had lying around. but the bolt isn't long enough to engage the nyloc part of the nut.)
>6 - M3*10 bolts (4 of these goes in the lead nut, 2 goes in the stepper motor bracket and into the stepper motor)
>2 - M3*14 bolts (these goes in the motor bracket)
>6 - M3 nuts (4 of these goes on the bolts through the lead nut. 2 of these go inside the motor bracket together with the m3*14 bolts exerts pressure on the gantry post to secure the motor bracket.)  
を用意します。秋葉原の西川電子部品さんにお世話になりました。

### 組み立て  
[KobraGoNeo Insights](https://1coderookie.github.io/KobraGoNeoInsights/hardware/mainboard/)によると、KobraNeoのメインボードは`TriGorillaV_3.0.6`で、コネクタの配置は下図のようになっています。
![](https://1coderookie.github.io/KobraGoNeoInsights/assets/images/mainboard_complete_labeled_web.jpg)
Z軸ステッピングモーター用のコネクタは一つしかないので、線を切って二股に分け、追加のモーターに接続しました。
ここで、並列にモーターの数が増えると必要な電圧も上がるため、ステッピングモータードライバーのVrefを上げる必要があります。
Printablesの説明では1.1Vまで上げたということでしたので、これを目指します。上図で右から二番目の赤丸で囲われているポテンショメータと、基板上の任意のGNDにテスターを当てて電圧を測り、ポテンショメータをゆっくり回しながら目標の電圧値になるまで調整します。

あとは、Printablesの写真を参考にしながら組み立てます。
完全に組み立てる前に、左右のモーターが同じ向きに回転しているかを確認しておいたほうが無難です。

これでデュアルZ軸にはなるんですが、X軸の両端が同じ高さになるように手動で調整する必要があるんですよね。これがちょっと面倒です。

## ファンシュラウド
オリジナルのファンシュラウドでは造形物の前面にしか風が当たりません。
印刷速度を上げようとすると、以下に素早く造形物を冷却できるかが重要になってきます。
ファンの種類や数を変えるのが最もラディカルですが、ファンの覆いを変えるだけでも一定の効果がありました。

https://www.printables.com/model/470004-anycubic-kobra-neo-fan-duct/comments
上記のモデルをPETGで印刷し、オリジナルのファンシュラウドと交換しました。
オーバーハングやブリッジの品質が改善したように思います。

## Klipper化
KobraNeoのファームウェアはMarlinですが、最近は[Klipper](https://www.klipper3d.org/)が流行ってきているようです。
KlipperはUIやステッピングモーターの動作の計算など、計算資源の必要な作業をRaspberryPiなどの汎用コンピュータにやらせ、
プリンター搭載のマイコンはモーターの操作等にのみ使うというコンセプトのものです。Klipperの搭載によって、印刷速度の向上や
Input Shapingによる印刷品質の向上が期待できるとされています。幸い、KobraNeoに搭載されている[Huada HC32F460 MCU](https://github.com/Klipper3d/klipper/commit/72b6bd7efa1ae282220b4bdcfb789075807ebfd2)はKlipperに公式でサポートされているため、簡単に試すことができます。

https://1coderookie.github.io/KobraGoNeoInsights/firmware/fw_klipper/
https://github.com/1coderookie/Klipper4KobraGoNeo

上記のリンクを参考にしながら、作業を進めます。操作用の汎用コンピュータには、RaspberryPi3Bを使いました。
ラズパイの固定には[自作のプリントパーツ](https://www.printables.com/model/567014-kobraneo-raspberrypi-holder)を使っています。

ラズパイ等のSBCでKlipperを使う方法はいくつかあるらしいのですが、今回は一番文献がありそうだった[Mainsail](https://docs.mainsail.xyz/)を用いました。
RaspbianベースのOSで、Klipperのファームウェア、プリンターとの通信モジュール、操作用のWebUIなどがセットになっています。RaspberryPi Imagerから直接インストールすることが可能です。

![](https://media.printables.com/media/prints/567014/images/4539143_e4f7287b-9870-4af3-9210-2f517625e9c1/thumbs/inside/1280x960/jpg/raspberrypi_holder.webp)
完成写真。ラズパイ取り付けの液晶のUIには、[KlipperScreen](https://klipperscreen.readthedocs.io/en/latest/)を使いました。

設定ファイルも基本的には上記Githubのものを使ったのですが、`printer.cfg`の`endstop_pin`を`^PC14`から`endstop_pin: probe:z_virtual_endstop`
に変更しました。これはベッドメッシュレベリングの際に、エンドピンを物理ピンにしたままだとプローブがベッドを検出する前に動作が止まってしまうからです。
自分の個体では、Z-offsetは+0.15くらいになりました。Z-offsetを保存する際に、エンドピンまでか、プローブまでかを聞かれますが、ここではプローブをエンドピンの代わりに利用しているため、「エンドピンまで」を選択します。肝心の造形品質ですが、たしかに表面の滑らかさは上がり、積層痕もかなり目立たなくなりました。また、これまでカクカクしていた動作がなめらかになり、それによって動作音も静かになった印象を受けます。加減速がスムーズでスマートに動くので、見ていて気持ちいいですね。
加速度センサーをプリントヘッドに取り付けてプリンターの振動を計測することで、それを打ち消すような制御を行うInput Shapingも実装されているということなので、
後日試してみようと思います。