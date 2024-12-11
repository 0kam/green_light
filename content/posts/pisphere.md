---
title: "PiSphere: RaspberryPi5で作る全天球タイムラプスカメラ"
date: 2024-12-06T10:33:31+09:00
tags: [raspberrypi]
draft: True
---
## はじめに


## 使用ハードウェア
- Raspberry Pi 5
- [Arducam fisheye camera with OV5647](https://www.uctronics.com/arducam-ultra-wide-angle-fisheye-5mp-ov5647-camera.html)
RaspberryPi Camera V1と同じOV5647センサーを採用した魚眼カメラモジュールです。
レンズはM12マウントで、視野角は220度です。
- [RTC battery pack for Raspberry Pi 5](https://www.switch-science.com/products/9254)
- 防水ボックス（タカチ電機工業BCAP151509G）
- Entaniya製フランジ付きアクリルドーム60mm (DC-60)
- ネジ類
 - M3 x 10 mm x 8
 - M3 x 16 mm x 4
 - M4 x 10 mm x 16

## 使用OS
RaspberryPi OS (64-bit, Bookworm)
VNC越しにリモートデスクトップからカメラのプレビューを見たいので、
デスクトップ環境のあるOSを推奨します。
```
$ uname -a
Linux raspberrypi 6.6.51+rpt-rpi-2712 #1 SMP PREEMPT Debian 1:6.6.51-1+rpt3 (2024-10-08) aarch64 GNU/Linux
```

## OSのセットアップ
- `$ sudo raspi-config`を実行し、Interface からSSHとVNCを有効化
ノートPCから実際の映像のプレビューを見るために、VNCで接続できるようにします。
- `$ sudo apt update && sudo apt upgrade -y`

### Real Time Clock (RTC) の設定
RPi5には本体の電源が切れている最中でも時刻を保持するRTC用のバッテリーを搭載することができます。
ここではRTCを利用して撮影の時間だけ起動するようにする間欠動作を実装し、小型のソーラーや
バッテリーだけでの動作ができるようにします。

- 以下を`/boot/firmware/config.txt`に追記し、再起動。
`/sys/devices/platform/soc/soc\:rpi_rtc/rtc/rtc0/charging_voltage_min`が`3000000`になっていることを確認。
```
dtparam=rtc_bbat_vchg=3000000
```
- `sudo -E rpi-eeprom-config --edit`を実行し、以下の設定になっていることを確認。
```
POWER_OFF_ON_HALT=1
WAKE_ON_GPIO=0
```

## PiSphereソフトウェアのインストール
```bash
git clone https://github.com/0kam/PiSphere.git
cd PiSphere
```

```bash
sudo ln -s /home/$USER/PiSphere/service/pisphere.service /etc/systemd/system/pisphere.service
sudo ln -s /home/$USER/PiSphere/service/pisphere.timer /etc/systemd/system/pisphere.timer
sudo systemctl enable pisphere.service
sudo systemctl start pisphere.service
sudo systemctl enable pisphere.timer
sudo systemctl start pisphere.timer
```
