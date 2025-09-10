---
title: "SongMeter Micro2のバッテリー増設とソーラー化"
date: 2025-07-31T06:30:30+09:00
tags: [音響生態学, songmeter]
draft: false
---

<img src=/images/songmeter/7e310b8d-08b2-4cf1-8328-cdcfaaf03035.png height=300>

## はじめに
鳥類やコウモリ、カエル、セミやコオロギなど、音を発する生き物は数多くいます。最近では、機械学習による鳴き声の自動判別手法の発展もあって、環境音を通して生態系のさまざまな側面（多様性や季節変化、行動など）を調べる音響生態学という分野ができつつあります。

こういった研究では、通常ARU (Automated Recording Unit, 自動録音ユニット)と呼ばれる音声レコーダーが使われます。ARUは1日の中で録音する時間を細かくスケジューリングすることができ、長期間の録音調査に便利です。現在（2025年）、音響生態学の研究でよく使われているARUはおおむね二つのシリーズです。
- [AudioMoth](https://www.openacousticdevices.info/audiomoth)
    - Open Acoustic Devices社のオープンソースのARU
    - 比較的安価 (防水ケースを含めて約$140)
    - 録音設定の変更にはPCとUSBケーブルで繋ぐ必要がある（不便！）
    - 単三電池3本で駆動
- [SongMeterシリーズ](https://www.wildlifeacoustics.com/)
    - Wildlife Acoustics社のARU
    - 電池の格納数やマイクの数などによってバリエーションがある
    - 値段もさまざま（$150 ~ $700）
    - スマホアプリで設定の変更や状況（電池残量など）の確認ができて便利
    - ケースなどの品質がAudioMothより良い

ARUを野外で運用する際にネックになってくるのは、バッテリー交換の頻度です。レコーダーは意外と電池食いです。例えばアルカリ単4電池4本で動作するSongMeterMicro2は、30分に10分の頻度で録音させた場合、2週間程度で電池が切れてしまいます。特にメンテナンスに行くのが大変な遠隔地に設置する際には、可能な限りバッテリー交換頻度を低くしたいものです。

SongMeterの高級モデル([SM4](https://www.wildlifeacoustics.com/products/song-meter-sm4), $700)は単一電池4本で動作できる上に、外部バッテリーやソーラーシステムに接続するオプションも用意されていますが、一番安価な[Micro2](https://www.wildlifeacoustics.com/products/song-meter-micro-2)($150)にはこのオプションはありません ~~（ケチな！）~~。

そこで、この記事ではSongMeterMicro2を単一電池4本、さらにはソーラーシステムで運用するための改造方法を紹介します。

## 注意点
- **ここで紹介する改造を行うと、メーカーによる保証の対象外になります。また、改造前と比較して防水性能が低下する可能性があります。改造は自己責任で行ってください。**
- **改造には電動ドリルやハンダゴテなど、正しく使わなければ危険を伴う機器を使います。くれぐれも気をつけて作業してください。**

## 必要な道具など
- 絶縁熱収縮チューブ（あればヒートガン）
- 短い結束バンド、タイベース（あれば）
- ハンダ、ハンダゴテ
- ニッパー、ワイヤーストリッパー
- トルクスねじ用ドライバー（T6, T9）
- 接着剤
    - 硬質プラスチックに使えるもの
    - ABSとポリカを接着します
    - おすすめはエポキシ系の2液性接着剤です

## 単一電池4本版
### 部品
- [SongMeter Micro2 (150USD) x 1](https://www.wildlifeacoustics.com/products/song-meter-micro-2)
- [タカチ防水防塵プラボックス BCAP151509G (約2000円) x 1](https://www.monotaro.com/p/8821/7394/)
- [タカチ防水ケーブルグランド RM8L-4B (約150円) x 1](https://www.monotaro.com/p/8836/5435/)
- 単一電池 x 4
    - ここでは、充電できるニッケル水素電池（[充電式IMPULSE](https://www.toshiba-lifestyle.com/jp/batteries/tnh-1a/)）を使用。アルカリより寒さに強く、冬季の高標高域での録音に向いています。
- 電池ボックス（単一2本を直列に繋げるもの ([例](https://akizukidenshi.com/catalog/g/g104984/)) x 2）
- 直径2.5 mm ~ 4 mm、2芯以上ある適当なケーブル（断面が丸いもののほうが良いです、20 cm程度）

<img src=/images/songmeter/f3d49f9e-141c-4035-9302-05d32a1e94f4.png height=400>

### 完成系

<img src=/images/songmeter/0ad14c2c-9d3b-4a35-8f80-63b627483b9a.png height=300>
<img src=/images/songmeter/3931e1f3-2fd9-4d5d-8527-df47cb3fafab.png height=300>
<img src=/images/songmeter/db7bb58f-b1e7-42bb-b6b2-6a0e6a39ecfc.png height=300>


### Step1. SongMeterの電池ボックスを取り外す
SongMeter Micro2に元々ついている電池ボックス（単3 x 4）を取り外します。
電池ボックスは左右二本の銀色のねじで止まっています。このねじはトルクスねじとなっており、専用のドライバーが必要です。20個ほど分解したところ、T6のトルクスねじが使われている場合と、T9が使われている場合がありました。電線は電池ボックス側で切ってしまいます。

<img src=/images/songmeter/b0534adf-9024-428d-8fbb-9b555c810642.png height=300>
<img src=/images/songmeter/8d23dae7-d7eb-4995-9066-8dd4112c8539.png height=300>

### Step2. 穴を開ける
SongMeterとプラボックスは防水のためケーブルグランドで接続します。
今回は取り付け穴8 mmのケーブルグランドを使っているため、8 mmの穴を両者に開けましょう。
右の写真のように、SongMeterとプラボックスを接着した際に正しい位置関係になるように穴の位置を合わせます。

<img src=/images/songmeter/4718239d-ea2b-41b8-900b-6b2c7e1cb67a.png height=200>
<img src=/images/songmeter/418c81ed-8a58-4f5b-937c-74a298d0615c.png height=200>

### Step3. SongMeterとプラボックスを接着する
両者に接着剤を塗り、貼り合わせます。この際、ケーブルグランドを通してから接着した方が良いでしょう。ケーブルグランドは、短いナットのついている方がSongMeter内に来るようにします。
<img src=/images/songmeter/08988080-aed3-4355-960f-28b0e763a082.png height=300>

### Step4. ケーブルを通す
ケーブルグランドにケーブルを通します。ケーブルグランドのプラボックス側は、分解するとゴムのパッキンが入っており、これを先にケーブルに通してからケーブルグランドに差し込み、長いナットで締め込みます。

<img src=/images/songmeter/3e98efd2-51a1-4f3f-b4eb-1cc84dd2293c.png height=300>
<img src=/images/songmeter/9e8f28f3-6745-45fc-b5cf-a9fd53398376.png height=300>
<img src=/images/songmeter/044aba8c-4c24-4f12-95cf-ee160de99f78.png height=300>

### Step5. 結線する
まずは、SongMeterの基盤から出ている線と、ケーブルグランドから出した線を結線します。線を寄り合わせてからハンダ付けし、熱収縮チューブで絶縁すると確実です。

<img src=/images/songmeter/0b347208-f6b9-426e-baff-1e6af7e37df2.png height=300>
<img src=/images/songmeter/3b032af3-2e03-4bdc-9b9a-cb9a3e777821.png height=300>

次に、プラボックスの中に電池ボックスを二つ入れ、直列に結線します。
直列なので、
```
本体+ → 電池ボックス1+ → 電池ボックス1- → 電池ボックス2+ → 電池ボックス2- → 本体-
```
の順番です。結線したら、電池ボックスをプラボックスに接着剤で止め、結束バンドとタイベース等で綺麗に配線します。

<img src=/images/songmeter/f7dd7401-da58-4725-82f1-3b9939cfafd1.png height=300>
<img src=/images/songmeter/6f7f9d5f-a79e-4c22-89e5-ecc7c76cdfc5.png height=300>

これで一通り完成しました！
以降はオプションです。

### オプション：3Dプリンター製の屋根と取り付けプレートの制作
このままでは、レコーダーを樹木や柱などに設置することができません。
さらに、SongMeterは蓋の開口部が露出しており、カード交換時などに水が侵入しないか気になります。
そこで、無料で使える3D CADソフトOnshapeを使って、プラボックスを樹木などに結束バンドで固定するための取り付けプレートと、簡単な屋根を設計しました。
3Dデータは[Onshape上で公開](https://cad.onshape.com/documents/773173789ef9010aa16c60cf/w/aa5432c2a5e11afa354f3c72/e/f5c2538e57dbe3ae6eea4b11?renderMode=0&uiState=6887295bbc425d248bb5497a)されているので、こちらからSTLファイルをダウンロードし、ご自身の3Dプリンターで印刷してください。
フィラメントは屋外での耐候性に優れた[ASAフィラメント](https://www.poly-maker.jp/polylite-asa.html)を推奨します。サポートは必要ありません。


## ソーラー版
### 部品
- 12V系5Wソーラーパネル 
（[例: SUNYOOO SY-M5W-12 (約1500円)](https://akizukidenshi.com/catalog/g/g114254/)）
- 12V1.2Ah鉛蓄電池
（[例: Long WP1.2-12（約1500円）](https://akizukidenshi.com/catalog/g/g106743/)）
- ソーラーチャージコントローラ
（[例: DENRYO Solar Amp B 12V10A 常時出力（約4000円）](https://akizukidenshi.com/catalog/g/g106606/)）
- 5VDCDCコンバータ
（例: [MINMAX M78AR05-0.5（約600円）](https://akizukidenshi.com/catalog/g/g107179/)）
- [タカチ防水ケーブルグランド MG-12S（約150円）x 1](https://www.monotaro.com/p/8822/3502/)
- 適当な電線
（赤黒の二色あると良い。各40cm程度）

以下は単一電池版と共通
- [SongMeter Micro2 (150USD) x 1](https://www.wildlifeacoustics.com/products/song-meter-micro-2)
- [タカチ防水防塵プラボックス BCAP151509G (約￥2000) x 1](https://www.monotaro.com/p/8821/7394/)
- [タカチ防水ケーブルグランド RM8L-4B (約150円) x 1](https://www.monotaro.com/p/8836/5435/)
- 直径2.5 mm ~ 4 mm、2芯以上ある適当な電線
（断面が丸いもののほうが良いです、20 cm程度）

<img src=/images/songmeter/ef15281d-0bf1-483a-a61d-80eb66395e6b.png height=400>
 

### 完成系

<img src=/images/songmeter/fe9d7387-16b3-4b2d-b8d1-808932b45a84.png height=300>


<img src=/images/songmeter/3a54357a-ca67-4c4b-9f2e-4fcf15565974.png height=300>


### Step1. SongMeterの電池ボックスを取り外す
電池版と同じなので省略します。

### Step2. 穴を開ける
SongMeterとプラボックス接続部は電池版と同じです。

ソーラー版では、ソーラーパネルからプラボックスへケーブルを伸ばす必要があります。
このケーブルを出す穴は、プラボックスの下部につけます。ソーラーパネルのケーブルもう少し大きいケーブルグランドをつけます。
今回は12 mmの取り付け穴を開けましょう。

<img src=/images/songmeter/c76fa3ff-5bdb-4ff8-9e8b-9b84cda49b56.png height=300>

### Step3. SongMeterとプラボックスを接着する
電池版と同じなので省略します。

### Step4. ケーブルを通す
SongMeterからプラボックスへ伸びるケーブルに関しては、電池版と同じなので省略します。
ソーラーパネルのケーブルにワニ口などがついている場合は切り落とし、大きい方のケーブルグランドを通してプラボックスに引き入れます。
<img src=/images/songmeter/740a3fd5-f57e-4f41-a403-7edc4f384c8e.png height=300>

### Step5. 結線する

以下のようなイメージで配線します。

<img src=/images/songmeter/30e72cea-2fe9-4c62-8e04-eb6341a97f0b.png height=400>

ソーラーパネルで発電した電力はソーラーチャージコントローラ（チャーコン）を介して電池を充電し、電池からはチャーコンとDCDCコンバータを介してSongMeterに給電します。

#### SongMeterとDCDCコンバータの接続
今回用いているソーラーシステムは12V系ですが、SongMeterは乾電池4本（≒6V）で駆動するため、電圧を下げる必要があります。ここでは、MINMAX社の高効率なDCDCコンバータを使い、5Vに降圧してからSongMeterに給電します。

まず、チャーコンからDCDCに接続するためのケーブル（10cm程度）を二本（プラス・マイナス）用意します。

次にDCDCとチャーコン側の線、SongMeter側の線を繋ぎます。DCDCには下の写真のように3本足が生えており、型番が書いている方を正面にした際の左側から、チャーコンのプラス線、チャーコン・SongMeterのマイナス線、SongMeterのプラス線、を繋ぎます。小さい基盤などにDCDCを留めてから配線した方が丁寧ですが、面倒なので直接線をはんだ付けして熱収縮チューブで絶縁してしまいました。

<img src=/images/songmeter/45bcf85d-8552-4dea-875e-3063d4c0cd5a.png height=300>
<img src=/images/songmeter/39c61c76-fc98-4b1f-a047-470e1770cf5e.png height=300>

#### チャーコンとSongMeter、バッテリー、ソーラーパネルの配線
次に、チャーコンへの配線を進めます。チャーコンはプラボックスの蓋に強力両面テープで貼りました。
まず、DCDCから伸びている線をチャーコンの負荷端子（電球マーク）に繋ぎます。
次に、チャーコンとバッテリーの接続用の電線を用意します。バッテリーの接続には[ファストン端子](https://akizukidenshi.com/catalog/g/g112033/)を使うと便利です。
持ち運び中にバッテリーが動いてしまう可能性もあるため、**接続は野外への設置時にする**方が無難です。
<img src=/images/songmeter/7e404d35-63f2-4315-84ba-f358e5540b7b.png height=300>

あとは、ソーラーパネルから伸びている電線をチャーコンのソーラーパネルアイコンの端子につければ完成です。こちらも、**設置時に接続**しましょう。

チャーコンへの接続の順番は、①SongMeter、②電池、③ソーラーパネルの順番に行うのが安全です。また、ソーラーパネルを取り付ける際には、パネルが発電しないように箱などに入れた状態で、ショートに十分注意しながら配線してください。

あとはバッテリー、ソーラーパネルをチャーコンに接続し、バッテリーをプラボックスに格納すれば完成です！
[バッテリーを箱の中で固定するためのジグ](https://cad.onshape.com/documents/773173789ef9010aa16c60cf/w/aa5432c2a5e11afa354f3c72/e/e2a60e87fd5921d3eee5d941?renderMode=0&uiState=688885bfbc425d248bb86ede)や、[ソーラーパネル（SY-M5W-12）を単管パイプ等に固定するためのジグ](https://cad.onshape.com/documents/773173789ef9010aa16c60cf/w/aa5432c2a5e11afa354f3c72/e/30478a14b40a370485b37ac6?renderMode=0&uiState=68897774cf876a2a07152228)も公開しています。ソーラーパネルは台風等の強風時に強い荷重がかかるので、金属製のジグで固定した方がいいかもしれません。

<img src=/images/songmeter/e156b327-c403-4ce6-abb3-d854d2d39d89.png height=300>


