---
title: "RaspberryPi 5のセットアップ"
date: 2024-02-14T11:03:50+09:00
tags: [RaspberryPi]
draft: false
---
## はじめに
RaspberryPi5（RPi5）がついに日本でも発売されましたね！
バッテリーでバックアップ可能なRealTimeClock(RTC)やUART用コネクタ、独自開発のI/Oチップ "RP1" 等の採用等、RPi5にはRPi4にはない特徴がいくつかあります。この記事では、RPi5のセットアップを行いながらこれらの新機能を試してみたいと思います。

## 動作環境
**OS**  
RaspberryPiOS Lite (64bit) Debian bookworm  
初回起動時にユーザー名とパスワードを入力  
`raspi-config`でシリアル通信を有効化  

**作業に使ったノートPC**    
Regolith Linux (Ubuntu 21.10)

## UART
従来のラズパイでもGPIO上に割り当てられたUARTピンを使ったシリアル通信は可能でしたが、RPi5ではGPIOから独立したUARTコネクタが用意されています。  
（参考：[公式ドキュメント](https://www.raspberrypi.com/documentation/computers/raspberry-pi-5.html#uart-connector)）  
ドキュメントには[公式のデバッグプローブ](https://www.raspberrypi.com/documentation/microcontrollers/debug-probe.html)の使用例が掲載されていますが、
当然3.3V系のUSBシリアル変換モジュールであれば何でも使うことができます。今回は秋月電子通商の[FT234X 超小型USBシリアル変換モジュール](https://akizukidenshi.com/catalog/g/g108461/)を使ってみました。  
ピンアウトは下図のようになっており、3ピンのJST-SHコネクタ（1.0 mmピッチ）を使って接続できます。SHコネクタの圧着は圧着工具がないとできないため、
[千石電商](https://www.sengoku.co.jp/mod/sgk_cart/search.php?cid=4283)等でケーブル付きのものを買うと便利です。

![](/images/rpi5/uart.png)

ノートPCとUSBシリアル変換モジュール、ラズパイのUARTコネクタを接続し、ノートPC上で`minicom -D /dev/ttyUSB0`を実行するとラズパイのシリアルコンソールにアクセスすることができます。デフォルトのボーレートは115200です。

![](/images/rpi/serial_console.png)

PCからラズパイへのアクセスにはSSHを使うことのほうが多い印象ですが、
ネットワーク設定の要らないUART接続も気軽で便利です。
また、ラズパイが突然起動しなくなり、SSHもできないときにブート時の出力を見ることができる、というメリットもあります。

## Real Time Clock (RTC)
  RPi5 は内蔵のリアルタイムクロック(RTC)を搭載しています。 RPi5の`BAT`と書かれた2ピンコネクタにバッテリーを接続することで、ラズパイに電源が供給されていないときにもRTCをバックアップし、時刻保持やアラームによる起動をおこなうことができます。公式のバッテリーにはパナソニック製のML2020リチウム二次電池が使われていますが、執筆時点では入手できなかったため、代替として [秋葉原の稲電気](https://www.google.co.jp/maps?q=%E6%9D%B1%E4%BA%AC%E9%83%BD%E5%8D%83%E4%BB%A3%E7%94%B0%E5%8C%BA%E5%A4%96%E7%A5%9E%E7%94%B0%EF%BC%91%E2%88%92%EF%BC%91%EF%BC%90%E2%88%92%EF%BC%91%EF%BC%91+%E7%A8%B2%E9%9B%BB%E6%A9%9F%EF%BC%88%E6%A0%AA%EF%BC%89&hl=ja&ie=UTF8&ll=35.698771,139.770856&spn=0.007946,0.016512&sll=35.698754,139.77077&sspn=0.007946,0.016512&oq=%E6%9D%B1%E4%BA%AC%E9%83%BD%E5%8D%83%E4%BB%A3%E7%94%B0%E5%8C%BA%E5%A4%96%E7%A5%9E%E7%94%B01-10-11%E3%80%80%E7%A8%B2&brcurrent=3,0x60188c1d19d478ff:0x8738b18b0465d817,0&hq=%E6%9D%B1%E4%BA%AC%E9%83%BD%E5%8D%83%E4%BB%A3%E7%94%B0%E5%8C%BA%E5%A4%96%E7%A5%9E%E7%94%B0%EF%BC%91%E2%88%92%EF%BC%91%EF%BC%90%E2%88%92%EF%BC%91%EF%BC%91+%E7%A8%B2%E9%9B%BB%E6%A9%9F%EF%BC%88%E6%A0%AA%EF%BC%89&t=m&z=17) で購入したML2032電池を使用しました。マイコン類のRTCバックアップにはCRシリーズのようなコイン型の一次電池が使われることが多いですが、公式ドキュメントでは、RPi5のRTCは消費電力が大きいため二次電池の使用が推奨されています。
  
  電池は2ピンのJST SHコネクターで下図のように接続します。
  ![](/images/rpi5/rtc.png)
  
  今回はML2032用のバッテリーケースの[3Dモデル](https://www.printables.com/model/763228-ml2032-coin-battery-holder) も設計し、3Dプリンターで印刷して使いました。
  
  ![](https://media.printables.com/media/prints/763228/images/5946592_4405a640-32fc-4d6b-836e-ac848ddbdb41_f4461794-0f60-4ea4-bd25-681d3daf7f83/thumbs/inside/1280x960/jpg/ml2032_holder.webp)
  
  ### ラズパイ側の設定
  デフォルトではRTCバックアップバッテリーの充電は無効化されているため、有効化する必要があります。
  `/boot/firmware/config.txt`に以下を追記し、再起動すると充電が有効化されます。
  ```
  dtparam=rtc_bbat_vchg=3000000
  ```
  また、シャットダウン時の待機電力を減らす省電力モードと、RTCからのwake alarmを有効化します。
  ```
  sudo -E rpi-eeprom-config --edit
  ```
  エディタが開かれるので、以下を書き込みます。POWER_OFF_ON_HALT にデフォルトで0が入っている場合は書き換えます。
  ```
  POWER_OFF_ON_HALT=1 
  WAKE_ON_GPIO=0
  ```
  ### ユースケース：間欠動作
  RTCの使用例として、毎日決まった時刻に起動・シャットダウンする間欠動作を実装してみます。例えば、夜間にだけラズパイを動かしたいときに昼の間は寝かせておくことで消費電力を大幅に削減できます。  
  これは、「毎日決まった時刻に、アラームをかけてシャットダウンする」ことで実現可能です。以下のシェルスクリプトのように、`/sys/class/rtc/rtc0/wakealarm`へ次回起動する時刻（UNIX時）を投げておくと、指定の時刻にラズパイを自動起動することができます。この例では10時間半のアラームをかけてからシャットダウンしています。
  ```
  date "+%s" -d "10 hours 30 minutes" > /sys/class/rtc/rtc0/wakealarm && /usr/sbin/telinit 0
  ```
  ここで、このRTCアラームを`cron`で定時に実行すれば、間欠動作ができます。例えば下の例では、毎日6:30にアラームをかけてシャットダウンしています。この作業にはroot権限が必要なため、`sudo crontab -u root -e`としてroot権限でcrontabを作成します。
  ```
  30 6 * * * /bin/bash /home/coot/virtual_net_zero_camera/shs/alarm.sh >> /home/coot/cron.log 2>&1
  ```
  これによって、上の例ではラズパイは毎日6:30にシャットダウンし、それから10時間半後の17:00にRTCアラームで自動起動することができます。