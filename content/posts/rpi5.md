---
title: "RaspberryPi 5の初期設定"
date: 2024-02-14T11:03:50+09:00
tags: [RaspberryPi]
draft: true
---
## はじめに
RaspberryPi5（RPi5）がついに日本でも発売されましたね！
バッテリーでバックアップ可能なRealTimeClock(RTC)やUART用コネクタ、独自開発のI/Oチップ "RP1" 等の採用等、RPi5にはRPi4にはない特徴がいくつかあります。この記事では、RPi5の初期設定を行いながらこれらの新機能を試してみたいと思います。

## 動作環境
- **OS**  
    RaspberryPiOS Lite (64bit) Debian bookworm  
    初回起動時にユーザー名とパスワードを入力  
    `raspi-config`でシリアル通信を有効化

- **作業に使ったノートPC**  
    Regolith Linux (Ubuntu 21.10)

## UART

## Real Time Clock (RTC)
