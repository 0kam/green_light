---
title: "安価な積雪深ロガーの自作"
date: 2025-11-19T06:30:51+09:00
tags: [Spresense, Arduino]
draft: false
---
## はじめに
積雪量は気候変動を考える上で重要な指標である一方、地形などによって空間的な不均質性が高くなりがちで計測が難しい対象だと言えます。大量に積雪深計をばら撒いてデータをたくさん取れると良いですが、ちゃんとした積雪深計は結構値段が高く（数十万円）、気軽に大量購入はできません。

一方、積雪深計の仕組み自体は簡単な（高いところにつけておいて、雪面までの距離を測れればいい）ので、自分でも作れるのでは？と思いました。

ここでは、Sony SpresenseとSeeed社の安価な超音波距離計を使って、1.5万円くらいで毎日決まった時間に積雪深を計測するロガーを作る方法をメモがわりに書いておきます。なお、本積雪深計はまだテストしておらず、精度も保証できません。

## 全体構成

![](/images/snowdepth_logger/logger.png)

### マイコン
今回は、Sony製のArduino互換マイコンSpresenseを使います。
Spresenseを使う理由は、

- Arduino互換で開発が楽
- GNSS、RTCが内蔵されており、野外での自動時刻校正や間欠動作が簡単に実装できる
- 拡張ボードを使えばmicroSDへのデータ書き込みも簡単

という感じで色々便利だからです。マイコンにしてはちょっと高いですが...

- [Sony Spresense](https://akizukidenshi.com/catalog/g/g114584/)
- [Spresense拡張ボード](https://akizukidenshi.com/catalog/g/g114585/)

### 超音波距離計
[Seeed Studio社の防水超音波距離センサー](https://www.switch-science.com/products/8872)を使いました。7.5mまで測れて防水、ケーブルグランド様の形状で箱への取り付けも簡単という便利な商品です。が、この記事を書いている時点で売り切れており、公式通販でも売ってなさそうなので終売っぽいですね。

やや測定範囲が狭いですが、[これ](https://www.switch-science.com/products/9215?_pos=26&_sid=acd8b4cd8&_ss=r)とかが代替になるかもしれません。

### トランシーバー
今回使った距離計はRS485で通信を行うので、データの受信にはトランシーバが必要です。
ここでは、[LTC485CN8](https://akizukidenshi.com/catalog/g/g102792/)を使いました。

### 電池
単三乾電池 x 4で駆動させます。

## 配線
LTC485CN8との通信にはSerial2を使い、RS485の受送信切り替えにはGPIO7を使います。
距離計とLTC485CN8の電源はSpresenseのVout(5.0V)から取りました。

![](/images/snowdepth_logger/fritzing.png)

## パッキング
箱は物置に転がっていたBoxcoの防水プラボックスを使いました。これはもう終売になっていますが、タカチで言うとBCAP101507Tくらいのサイズ感のものです（外寸140mm x 100mm x 85mm程度）。

ボックスの底面に29mmの穴を開け、距離計を固定します。
乾電池4本を入れた電池ボックスも一緒に格納しました。

## Arduinoスケッチ

ソフトウェアはArduinoIDEを使って開発しました。
実装した主な機能は以下のような感じです。

- 起動時にGNSSシグナルを受信してRTC（内部時計）を校正
- 冒頭の"schedule"で指定された時刻にロギングを実施  
  例：毎時0分、30分にロギング
  ```cpp
    schedule s = {0,24, {0, 30}};
  ```
- 1回のロギングでは1秒間隔で10回距離計測
- 1回のロギングごとにCSVを作成して保存
- ロギングが終わったら次の起動時刻を計算してディープスリープ

<details>
<summary> Arduinoスケッチ </summary>

```cpp
/*
---------------------
Name: RS485_US_sensor.ino
Author: Ryotaro Okamoto
Started: 2025/11/19
Last Modified: 2025/11/19
Purpose: To perform time-lapse logging of snow depth level using Sony Spresense
---------------------
Description:
Ultrasonic Level Sensor : https://www.seeedstudio.com/RS485-750cm-Ultrasonic-Level-Sensor-p-5587.html?qid=8E73JB_4boj71q2_1763535329310
RS485 transceiver : https://akizukidenshi.com/catalog/g/g102792/
*/


/* Libraries
-----------------------------------------------------------------------------------------------*/
#include <Arduino.h>
// Below is for Spresense
#include <GNSS.h>
#include <LowPower.h>
#include <arch/board/board.h>
#include <RTC.h>
#include <Watchdog.h>
#include <SDHCI.h>

/* Defining pins for the level sensor
-----------------------------------------------------------------------------------------------*/
#define RS485_TXEN_PIN 7   // LTC485 DE/RE 制御ピン
#define RS485_SERIAL Serial2 // Use UART2
#define GNSS_STATUS_LED 6 // GNSSの受信状況を表示するLEDのピン。VCC -> LED -> GNSS_STATUS_LED の順に繋ぐ。LOWで点灯。

const uint8_t SLAVE_ADDR = 0x01;
const uint16_t REG_DISTANCE = 0x0100;
const uint8_t FUNC_READ = 0x03;

// ロギング回数
const int num_count = 10;   // 1回のロギングで何回計測するか。計測結果は全てCSVに保存する。
const int measure_interval_ms = 1000;  // 1秒ごと
SDClass theSD;

/* Defining the schedule structure
-----------------------------------------------------------------------------------------------*/
typedef struct { 
 int start_h;
 int end_h;
 int m[100];
} schedule;

#define BAUDRATE 115200
#define MY_TIMEZONE_IN_SECONDS (9 * 60 * 60) // 9 * 60 * 60 means JST. Modify if required since the GNSS time is UTC.
const int wd_time = 65000; // Watchdog time in ms. if the main loop took more than wd_time, the watchdog will reset the process.


/* Time-lapse Parameters
-----------------------------------------------------------------------------------------------*/
schedule s = {0,24, {0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55}}; // {start time (O'clock), end time (O'clock), {start time in every hour}}
// Example: schedule s = {9,18, {0, 30}}; means that the logging starts at 0min, 30min in every hour from 9:00 to 18:00.
//If you specify s = {17,7,{0,20,40}}, The logging will be start at 17:00 and stop at 7:00 (7:20 and 7:40 will not be created).

/* デバッグモード切り替え
---------------------------------------------------------------------------------------------*/
// デバッグ用フラグ（開発時はtrue、運用時はfalse）。trueにするとシリアル出力が出る。
#define DEBUG_MODE false

// デバッグ用マクロ
#if DEBUG_MODE
  #define DEBUG_PRINT(x) Serial.print(x)
  #define DEBUG_PRINTLN(x) Serial.println(x)
  #define DEBUG_BEGIN(x) Serial.begin(x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
  #define DEBUG_BEGIN(x)
#endif

/* For timelapse operation
-----------------------------------------------------------------------------------------------*/
// Define when to start logging
static const int logging_start_second = 0; // start logging at 0 sec of each minutes
// Wating time between boot and logging
static const int boot_to_record_delay = 10; // boot 10 sec earlier than the logging time

const char* boot_cause_strings[] = {
  "Power On Reset with Power Supplied",
  "System WDT expired or Self Reboot",
  "Chip WDT expired",
  "WKUPL signal detected in deep sleep",
  "WKUPS signal detected in deep sleep",
  "RTC Alarm expired in deep sleep",
  "USB Connected in deep sleep",
  "Others in deep sleep",
  "SCU Interrupt detected in cold sleep",
  "RTC Alarm0 expired in cold sleep",
  "RTC Alarm1 expired in cold sleep",
  "RTC Alarm2 expired in cold sleep",
  "RTC Alarm Error occurred in cold sleep",
  "Unknown(13)",
  "Unknown(14)",
  "Unknown(15)",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "GPIO detected in cold sleep",
  "SEN_INT signal detected in cold sleep",
  "PMIC signal detected in cold sleep",
  "USB Disconnected in cold sleep",
  "USB Connected in cold sleep",
  "Power On Reset",
};

void printBootCause(bootcause_e bc)
{
  DEBUG_PRINTLN("--------------------------------------------------");
  DEBUG_PRINT("Boot Cause: ");
  DEBUG_PRINT(boot_cause_strings[bc]);
  if ((COLD_GPIO_IRQ36 <= bc) && (bc <= COLD_GPIO_IRQ47)) {
    // Wakeup by GPIO
    int pin = LowPower.getWakeupPin(bc);
    DEBUG_PRINT(" <- pin ");
    DEBUG_PRINT(pin);
  }
  DEBUG_PRINTLN();
  DEBUG_PRINTLN("--------------------------------------------------");
}

SpGnss Gnss;

String printClock(RtcTime &rtc)
{
  char buf [13];
  sprintf(buf,
          "%04d%02d%02d_%02d%02d",
          rtc.year(), rtc.month(), rtc.day(),
          rtc.hour(), rtc.minute()
        );
  String str = String(buf);
  return str;
}

void setRTC()
{
  // Initialize RTC at first
  RTC.begin();

  // Initialize and start GNSS library
  int ret;
  ret = Gnss.begin();
  assert(ret == 0);
  
  Gnss.select(GPS); // GPS
  Gnss.select(QZ_L1CA); // QZSS  
  Gnss.select(QZ_L1S);

  ret = Gnss.start();
  assert(ret == 0);

  // Wait for GNSS data
  int led_state = 0;
  while (true)
  {
    if (Gnss.waitUpdate()) {
      SpNavData  NavData;
  
      // Get the UTC time
      Gnss.getNavData(&NavData);
      SpGnssTime *time = &NavData.time;
  
      // Check if the acquired UTC time is accurate
      DEBUG_PRINTLN(time->year);
      if (time->year > 2000 && time->year < 2100) {
        RtcTime now = RTC.getTime();
        // Convert SpGnssTime to RtcTime
        RtcTime gps(time->year, time->month, time->day,
                    time->hour, time->minute, time->sec, time->usec * 1000);
        // Set the time difference
        gps += MY_TIMEZONE_IN_SECONDS;
        int diff = now - gps;
        if (abs(diff) >= 1) {
          RTC.setTime(gps);
        }
        if (Gnss.stop() != 0)                
        {
          DEBUG_PRINTLN("Gnss stop error!!");
        }
        else if (Gnss.end() != 0)            
        {
          DEBUG_PRINTLN("Gnss end error!!");
        }
        digitalWrite(GNSS_STATUS_LED, HIGH);
        break;        
      }      
    }
    // While wating for GNSS signals, the green LED of the Spresense Main Board will be blinking slowly
    DEBUG_PRINTLN("Waiting for GNSS signals...");
    if (led_state == 0)
    {
      digitalWrite(GNSS_STATUS_LED, LOW);
      led_state = 1;
    }
    else
    {
      digitalWrite(GNSS_STATUS_LED, HIGH);
      led_state = 0;
    }
  }
}

void setLowPower()
{
  bootcause_e bc = LowPower.bootCause();
  if ((bc == POR_SUPPLY) || (bc == POR_NORMAL)) {
    DEBUG_PRINTLN("First boot!");
  } else {
    DEBUG_PRINTLN("wakeup from deep sleep");
  }
  // Print the boot cause
  printBootCause(bc);
}

void findMinute(schedule s, int *next_minute, int *next_hour, int *next_date, RtcTime &rtc)
{
  bool find_m = false;
  int i;
  int m_len = sizeof(s.m) / sizeof(int);
  
  // Find a minute later than current time
  for (i = 0; i < m_len; i++)
  {
    if (s.m[i] > rtc.minute()){
      *next_minute = s.m[i];
      *next_hour = rtc.hour();
      *next_date = rtc.day();  // No date change since it's within the same hour
      find_m = true;
      break;
    }
  }
  
  // If no minute found later than current time, use the first minute of next hour
  if (!find_m)
  {
    *next_minute = s.m[0];
    *next_hour = rtc.hour() + 1;
    *next_date = rtc.day();
    
    // Handle case when hour exceeds 24
    if (*next_hour >= 24)
    {
      *next_hour = 0;
      *next_date = rtc.day() + 1;
    }
  }
}

void waitUntilShootTime()
{
  // クロックを下げる
  DEBUG_PRINTLN("Wating...");
  LowPower.clockMode(CLOCK_MODE_8MHz);
  RtcTime now = RTC.getTime();
  int target_second = logging_start_second;
  
  // 目標秒まで何秒待つ必要があるか計算
  int seconds_to_wait;
  if (now.second() <= target_second) {
    seconds_to_wait = target_second - now.second();
  } else {
    seconds_to_wait = 60 - now.second() + target_second;
  }
  
  // 1秒以上待つ必要がある場合はその秒数分delay
  if (seconds_to_wait > 1) {
    delay(seconds_to_wait - 1);  // 1秒前に起きる
  }
  
  // 最後の1秒以下は通常の待機（精度のため）
  now = RTC.getTime();
  while (now.second() != target_second)
  {
    delay(10);
    now = RTC.getTime();
  }
  LowPower.clockMode(CLOCK_MODE_32MHz);
}

int getNextAlarm(schedule s, RtcTime &rtc)
{
  int next_hour;
  int next_minute = s.m[0];
  int next_date = rtc.day();
  
  if (s.start_h > s.end_h)  // Date-crossing schedule (e.g., 17:00~5:00)
  {
    if (rtc.hour() < s.start_h)  // Current time is before start time
    {
      if (rtc.hour() < s.end_h)  // Current time is before end time (within logging period)
      {
        findMinute(s, &next_minute, &next_hour, &next_date, rtc);
      }
      else  // Current time is outside logging period (e.g., between 5:00~17:00)
      {
        next_hour = s.start_h;
        next_minute = s.m[0];
        next_date = rtc.day();  // Start time of today
      }      
    }
    else  // Current time is after start time (within logging period)
    {
      findMinute(s, &next_minute, &next_hour, &next_date, rtc);
      
      // Important: Handle case when next logging time exceeds end time
      if (next_hour >= 24)  // When it goes to next day
      {
        if ((next_hour % 24) >= s.end_h)  // When it exceeds end time of next day
        {
          next_hour = s.start_h;
          next_minute = s.m[0];
          next_date = rtc.day() + 1;  // Start time of next day
        }
      }
    }
  }
  else  // Normal schedule (no date crossing)
  {
    if ((rtc.hour() >= s.start_h) & (rtc.hour() <= s.end_h))
    {
      findMinute(s, &next_minute, &next_hour, &next_date, rtc);
    } else if (rtc.hour() < s.start_h) 
    {
      next_hour = s.start_h;
      next_minute = s.m[0];
      next_date = rtc.day();
    }
    else
    {
      next_hour = s.start_h;
      next_minute = s.m[0];
      next_date = rtc.day() + 1;
    }
  }
  
  // Specify logging start time down to seconds
  RtcTime rtc_record_start = RtcTime(rtc.year(), rtc.month(), next_date, 
                                     next_hour, next_minute, logging_start_second);
  
  // Boot time is boot_to_record_delay seconds before logging start time
  RtcTime rtc_to_alarm = rtc_record_start - boot_to_record_delay;
  
  String str_record = printClock(rtc_record_start); 
  String str_boot = printClock(rtc_to_alarm);
  DEBUG_PRINTLN("Next logging time: " + str_record);
  DEBUG_PRINTLN("Next boot time: " + str_boot);
  
  int sleep_sec = rtc_to_alarm.unixtime() - rtc.unixtime();
  if (sleep_sec < 0)
  {
    sleep_sec = 0;
  }
  return sleep_sec;
}

/* For operating the Ultrasonic Level Sensor
-----------------------------------------------------------------------------------------------*/
// calulate CRC16
uint16_t calcCRC16(const uint8_t *buf, uint8_t len) {
  uint16_t crc = 0xFFFF;
  for (uint8_t pos=0; pos<len; pos++) {
    crc ^= (uint16_t)buf[pos];
    for (uint8_t i=0; i<8; i++) {
      if (crc & 0x0001) {
        crc >>= 1;
        crc ^= 0xA001;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc;
}

void sendReadCommand(uint8_t slave, uint8_t func, uint16_t reg, uint16_t count) {
  uint8_t buf[8];
  buf[0] = slave;
  buf[1] = func;
  buf[2] = (reg >> 8) & 0xFF;
  buf[3] = reg & 0xFF;
  buf[4] = (count >> 8) & 0xFF;
  buf[5] = count & 0xFF;
  uint16_t crc = calcCRC16(buf, 6);
  buf[6] = crc & 0xFF;
  buf[7] = (crc >> 8) & 0xFF;

  digitalWrite(RS485_TXEN_PIN, HIGH); // 送信モード
  RS485_SERIAL.write(buf, 8);
  RS485_SERIAL.flush();
  digitalWrite(RS485_TXEN_PIN, LOW);  // 受信モード
}

bool readResponse(uint16_t &distance_mm) {
  // 適切なバッファ長（例、返りバイト数6＋データ？）を監視
  if (RS485_SERIAL.available() < 7) return false;
  uint8_t header[3];
  RS485_SERIAL.readBytes(header, 3);
  // header[0]=slave, header[1]=func, header[2]=byte count
  uint8_t byteCount = header[2];
  if (byteCount < 2) return false;
  uint8_t data[2];
  RS485_SERIAL.readBytes(data, 2);
  uint8_t crcBytes[2];
  RS485_SERIAL.readBytes(crcBytes, 2);

  // CRCチェック
  uint8_t checkBuf[5];
  checkBuf[0] = header[0];
  checkBuf[1] = header[1];
  checkBuf[2] = header[2];
  checkBuf[3] = data[0];
  checkBuf[4] = data[1];
  uint16_t calc = calcCRC16(checkBuf, 5);
  uint16_t rec = ((uint16_t)crcBytes[1]<<8) | crcBytes[0];
  if (calc != rec) {
    return false;
  }

  distance_mm = ((uint16_t)data[0]<<8) | data[1];
  return true;
}

// num_count回分の計測を1ファイルに書き込む
void logCSV() {
  RtcTime now = RTC.getTime();

  // ファイル名生成（開始時刻）
  char filename[32];
  snprintf(filename, sizeof(filename),
           "%04d%02d%02d_%02d%02d.csv",
           now.year(), now.month(), now.day(),
           now.hour(), now.minute());

  File f = theSD.open(filename, FILE_WRITE);

  if (!f) {
    DEBUG_PRINTLN("File open failed");
    return;
  }

  // CSVヘッダー
  f.println("Datetime,Distance_mm");

  DEBUG_PRINT("Logging to: ");
  DEBUG_PRINTLN(filename);

  // num_count回の計測ループ
  sendReadCommand(SLAVE_ADDR, FUNC_READ, REG_DISTANCE, 1); // 一回空打ちしておく
  delay(measure_interval_ms);
  for (int i = 0; i < num_count; i++) {

    uint16_t dist;
    bool ok = false;

    sendReadCommand(SLAVE_ADDR, FUNC_READ, REG_DISTANCE, 1);

    unsigned long t0 = millis();
    while (millis() - t0 < 300) {
      if (readResponse(dist)) {
        ok = true;
        break;
      }
    }

    // 現在時刻を取得
    now = RTC.getTime();

    // 書き込み
    if (ok) {
      f.printf("%04d-%02d-%02d %02d:%02d:%02d,%u\n",
               now.year(), now.month(), now.day(),
               now.hour(), now.minute(), now.second(),
               dist);
    } else {
      DEBUG_PRINTLN("Read error");
    }

    delay(measure_interval_ms);
  }

  // ファイルを閉じる（安全）
  f.close();

  DEBUG_PRINTLN("Logging complete.");
}


void setup() {
  DEBUG_BEGIN(115200);
  LowPower.clockMode(CLOCK_MODE_32MHz);
  board_xtal_power_control(true);
  pinMode(GNSS_STATUS_LED, OUTPUT);
  digitalWrite(GNSS_STATUS_LED, HIGH);
  delay(1000);
  
  // Setup timelapse functions
  DEBUG_PRINTLN("Starting!");
  setRTC();
  setLowPower();
  Watchdog.begin();
  Watchdog.start(wd_time);

  // Setup Level sensor functions
  RS485_SERIAL.begin(9600);
  pinMode(RS485_TXEN_PIN, OUTPUT);
  digitalWrite(RS485_TXEN_PIN, LOW);
  if (!theSD.begin()) {
    DEBUG_PRINTLN("SD init failed");
    while (1);
  }
  DEBUG_PRINTLN("SD OK");
}

bool rec_ok = true;
String file_name;
int sleep_sec;
RtcTime now;

void loop() {
  Watchdog.kick();
  waitUntilShootTime();
  logCSV();

  now = RTC.getTime();
  sleep_sec = getNextAlarm(s, now);
  
  if (sleep_sec > 0)
  {
    DEBUG_PRINT("Go to deep sleep...");
    LowPower.clockMode(CLOCK_MODE_8MHz);
    board_xtal_power_control(false);
    LowPower.deepSleep(sleep_sec);
  } 
}
```
</details>

## 消費電力
電池の持ちを予測するために、消費電力を計測しました。計測には、NORDIC Semiconの[Power Profiler Kit 2 (ppk2)](https://www.nordicsemi.jp/tools/ppk2/)を使いました。

まずはロギング時の消費電力を見てみます。
ロギング開始前の待機時間にちょっと消費電流が大きいですね...
`waitUntilShootTime()`をもう少し工夫した方がいいのかもしれませんが、トータルで 24.22 * 27.83 = 675 mAs = 0.1875 mAh 使っていることがわかります。

![](/images/snowdepth_logger/power_consumption_logging.png)

次にディープスリープ時の消費電力です。[色々工夫すればもっと減らせそう](https://ja.stackoverflow.com/questions/55366/sony-spresense-deep-sleep%E3%81%A7%E3%81%AE%E9%9B%BB%E5%8A%9B)ですが、現状 5.43 mA 程度使っている様ですね。

![](/images/snowdepth_logger/power_consumption_sleeping.png)

以上から、毎時1回ロギングした場合の1日あたりの消費電力を計算します。

まず、ディープスリープ時に 5.43 * 24 = 130.32 mAh 使います。

それに加えてロギング時に、
0.1875 * 24 = 4.5 mAh = 22.5 mWh 使います。

アルカリ乾電池は一般に寒さに弱いため、使うとしたらリチウム乾電池か、エネループのようなニッケル水素充電池でしょう。
一応、距離計の動作電圧は5~12Vとなっているため、1.2Vのニッケル水素4本だと電圧が若干足りません。問題ない気もしますが、リチウム乾電池を使う想定にします。

一般的なリチウム乾電池の容量は3000 mAh程度だと考えられるので、4本つけた際の容量は 3000 mAh * 6 V = 18000 mWh 程度だと思われます。

したがって、理想的には18000 / 22.5 = 800 日間持つ想定です。（本当か！？）

## 使ってみた
今冬長野の山奥で試験予定です！Coming Soon!