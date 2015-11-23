# 観測の実施

## ガンマ線イベントの取得

### 積分時間を指定した実行

以下のようにDAQソフトウエアを実行すると、指定した積分時間でガンマ線データの取得ができます。

```
growth_fy2015_adc_measure_exposure /dev/ttyUSB0 configuration_20151022_xxxx.yaml 1800
```

このDAQソフトウエアでは、実行時刻がファイル名となってイベントファイルが保存されます。

```
例: 20151026_0010.fits
```

### コンフィグレーションファイルの内容

```yaml
DetectorID: fy2015_version_a                 # detector ID (e.g. fy2015a, fy2015b, ... )
PreTriggerSamples: 31                        # look-back samples (max 32)
PostTriggerSamples: 800                      # number of samples after trigger
SamplesInEventPacket: 831                    # number of samples stored in the event packet
DownSamplingFactorForSavedWaveform: 1        # reserved
ChannelEnable: [yes,yes,yes,yes]             # channel enable for ch. 0/1/2/3
TriggerThresholds: [810, 510, 810, 520]      # threshold for ch. 0/1/2/3
TriggerCloseThresholds: [800, 490, 800, 500] # trigger close threshold for ch. 0/1/2/3
```

___注意___

- DetecotrIDはFITSファイルのヘッダに記録されます。
- PreTriggerSamplesはトリガ前の波形を、FPGA内部のイベント処理の中でどれくらい残すかを指定します。
  イベントファイルに記録されるbaselineは、記録した波形の最初の4サンプルの平均を出しているので、
  トリガ地点よりある程度戻っておかないと正確なベースラインになりません。
  通常は```PreTriggerSamples: 32```としておけば良いと思います。
  最大値(32)以上の値を設定すると、```PreTriggerSamples: 0```としたことと同じ動作になります。
- SamplesInEventPacketを増やすと、イベントファイルの中に記録される波形が長くなります。
  同時に、イベントパケット1個のサイズも増加するため、シリアル通信で読み出せるデータレートを簡単に
  超えてしまい、FPGA内部でバッファフルが発生し、トリガしたイベントが捨てられることになります。
  たとえば、アンプ回路のデバッグのときは波形をたくさん残すようにして、正常動作が確認できたあと、
  長時間観測のときは```SamplesInEventPacket: 1```にする、という使い方が良いと思います。

## 出力されるFITSファイル

ROOTをそのまま動作させるのはRaspberry Piにとっては結構な負荷になるので、
Raspberry Pi上のDAQソフトウエアでは、ROOTファイル形式は採用していません(Macでは使えます)。
代わりに、cfitsioを用いてFITSファイルとしてイベントリストを保存します。
FITS形式の場合、イベントリストをfvで開いて直接中身をみたり、phaMaxをヒストグラムとして詰めたり、
waveformをプロットしたりできるので、それなりの良さが有ります。fselectを使うと、特定のイベントだけ
抜き出すこともできます。

以下にFITS形式のイベントリストファイルのフォーマットを解説します。

### EVENTS extension

EVENTS extensionのヘッダは以下のようになっています。

```yaml
XTENSION= 'BINTABLE'           / binary table extension
BITPIX  =                    8 / 8-bit bytes
NAXIS   =                    2 / 2-dimensional binary table
NAXIS1  =                   27 / width of table in bytes
NAXIS2  =                32000 / number of rows in table
PCOUNT  =                    0 / size of special data area
GCOUNT  =                    1 / one data group (required keyword)
TFIELDS =                   11 / number of fields in each row
TTYPE1  = 'boardIndexAndChannel' / label for field   1
TFORM1  = 'B       '           / data format of field: BYTE
TTYPE2  = 'timeTag '           / label for field   2
TFORM2  = 'K       '           / data format of field: 8-byte INTEGER
TTYPE3  = 'triggerCount'       / label for field   3
TFORM3  = 'I       '           / data format of field: 2-byte INTEGER
TZERO3  =                32768 / offset for unsigned integers
TSCAL3  =                    1 / data are not scaled
TTYPE4  = 'phaMax  '           / label for field   4
TFORM4  = 'I       '           / data format of field: 2-byte INTEGER
TZERO4  =                32768 / offset for unsigned integers
TSCAL4  =                    1 / data are not scaled
TTYPE5  = 'phaMaxTime'         / label for field   5
TFORM5  = 'I       '           / data format of field: 2-byte INTEGER
TZERO5  =                32768 / offset for unsigned integers
TSCAL5  =                    1 / data are not scaled
TTYPE6  = 'phaMin  '           / label for field   6
TFORM6  = 'I       '           / data format of field: 2-byte INTEGER
TZERO6  =                32768 / offset for unsigned integers
TSCAL6  =                    1 / data are not scaled
TTYPE7  = 'phaFirst'           / label for field   7
TFORM7  = 'I       '           / data format of field: 2-byte INTEGER
TZERO7  =                32768 / offset for unsigned integers
TSCAL7  =                    1 / data are not scaled
TTYPE8  = 'phaLast '           / label for field   8
TFORM8  = 'I       '           / data format of field: 2-byte INTEGER
TZERO8  =                32768 / offset for unsigned integers
TSCAL8  =                    1 / data are not scaled
TTYPE9  = 'maxDerivative'      / label for field   9
TFORM9  = 'I       '           / data format of field: 2-byte INTEGER
TZERO9  =                32768 / offset for unsigned integers
TSCAL9  =                    1 / data are not scaled
TTYPE10 = 'baseline'           / label for field  10
TFORM10 = 'I       '           / data format of field: 2-byte INTEGER
TZERO10 =                32768 / offset for unsigned integers
TSCAL10 =                    1 / data are not scaled
TTYPE11 = 'waveform'           / label for field  11
TFORM11 = '1I      '           / data format of field: 2-byte INTEGER
TZERO11 =                32768 / offset for unsigned integers
TSCAL11 =                    1 / data are not scaled
EXTNAME = 'EVENTS  '           / name of this binary table extension
FILEDATE= '20151023_000859'    / fileCreationDate
DET_ID  = 'fy2015_version_a'   / detectorID
NSAMPLES=                    1 / nSamples
EXPOSURE=             1.80E+03 / exposure specified via command line
HISTORY YAML-- DetectorID: fy2015_version_a
HISTORY YAML-- PreTriggerSamples: 31
HISTORY YAML-- PostTriggerSamples: 800
HISTORY YAML-- SamplesInEventPacket: 1
HISTORY YAML-- DownSamplingFactorForSavedWaveform: 1
HISTORY YAML-- ChannelEnable: [no,yes,no,no]
HISTORY YAML-- TriggerThresholds: [810, 500, 810, 800]
HISTORY YAML-- TriggerCloseThresholds: [800, 495, 800, 800]
HISTORY YAML--
END
```

detectorIDは```DET_ID```に記録されます。

```
DET_ID  = 'fy2015_version_a'   / detectorID
```

イベントパケットに記録されたwaveformのサンプル数は```NSAMPLES```に記録されています。
この数が、waveformカラムの要素数に対応します。
長時間観測のように、波形を記録しなくてよい場合は長さ1にしてください。

```
NSAMPLES=                    1 / nSamples
```

コマンドラインで指定した測定時間は秒単位でEXPOSUREに記録されます。
```
EXPOSURE=             1.80E+03 / exposure specified via command line
```

```HISTORY YAML--```の行は、configuration fileのコピーを保存しています。


カラム定義は以下のようになっています。

|TTYPE|TFORM|TZERO|データ型|コメント|
|:---:|:---:|:---:|:---:|:---|
|boardIndexAndChannel|B|-|uint8_t|チャネル番号|
|timeTag|K|-|int64_t|FPGAローカルクロックのtime tag(40it; 分解能はTIMERESキーワード参照)|
|triggerCount|I|32768|uint16_t|トリガカウンタ|
|phaMax|I|32768|uint16_t|最大波高値|
|phaMaxTime|I|32768|uint16_t|最大波高値を迎えたサンプル番号|
|phaMin|I|32768|uint16_t|最小波高値|
|phaFirst|I|32768|uint16_t|トリガ内の最初のサンプルの波高値|
|phaLast|I|32768|uint16_t|トリガ内の最後のサンプルの波高値|
|maxDerivative|I|32768|uint16_t|トリガした波形内の微分の絶対値の最大値|
|baseline|I|32768|uint16_t|トリガした波形の最初の4サンプルの平均値|
|waveform|I×N|32768|uint16_t|波形データ(N=nSamples)|

基礎性能測定試験などで、waveformを記録する方程式で測定を実施した場合は、fvなどで波形を確認できます。


### GPS extension

GPSの1PPSにあわせて記録されたFPGAのローカルクロックのtime tagと、GPSの絶対時刻の文字データを記録しています。後段の時刻付ソフトウエアで較正データとして使用します。

|TTYPE|TFORM|TZERO|データ型|コメント|
|:---:|:---:|:---:|:---:|:---|
|timeTag|K|-|int64_t|FPGAローカルクロックのtime tag(40bit; 分解能はTIMERESキーワード参照)|
|gpsTime|20A|-|char[20]|GPSのYYMMDD HH:MM:SS|
|unixTime|J|2147483648|uint32_t|Raspberry Pi上のUNIX Time|

## ロングラン観測用のループ実行

### growth_configを用いた初期設定

実際の観測運用において、ガンマ線のDAQとHKの記録を繰り返し実行するスクリプトも用意されています。
それらのスクリプトは、detectorIDが```~/growth_config.yaml```に保存されていることを前提としているので、以下のコマンドで最初にセットアップしてください。

```sh
growth_config -g
```

これを実行すると、detectorIDを入力するよう促されるので、```growth-fy2015x```と入力してリターンを入力します。保存されたかどうかを確認するためには、

```
growth_config -i
```

としてください。意図した通りのdetectorIDが表示されていればOKです。

詳細は§3 セットアップの「<a href="#growth_config.yamlの作成">growth_config.yamlの作成</a>」の項を参考にしてください。

### ロングランの事前準備

1. ロングランに入る前に、「<a href="#ロングラン用ディレクトリの準備">ロングラン用ディレクトリの準備</a>」の項を参考にして、HDDにデータを保存するためのディレクトリを作成してください。
1. rsyncスクリプトをHDD直下にコピーしてください(「[rsyncスクリプトをコピー](#rsyncスクリプトをコピー)」の項参照)。
1. ロングラン用ディレクトリ(/media/hdd/growth/data/growth-fy2015x/)の中に、```configuration_without_wf.yaml```という、ロングラン用のconfiguration fileを用意してください(「[ロングラン用ディレクトリの準備](#ロングラン用ディレクトリの準備)」を参照)。
1. 「[Raspberry Piのssh-keyの作成・登録](#Raspberry Piのssh-keyの作成・登録)」の項を参考にして、解析サーバにパスワードなしでrsyncできるようにしておいてください。 
1. AT&T M2Xクラウドへの温度データの通知、mydns等dynamic DNSへのIPアドレスの通知を行うスクリプトをホームディレクトリに準備してください(「[M2Xへの通知、IPアドレスの通知](#M2Xへの通知、IPアドレスの通知)」の項参照)。

### ロングランの際に実行するループ

ロングランの際には、以下の処理が繰り返し実行されるようにします。

1. DAQソフトウエアのループ実行(```go_loop_daq.sh```)
1. HK取得ソフトウエアのループ実行(```go_loop_hk.sh```)
1. ウェブカメラによる撮影スクリプトのループ実行(```go_loop_webcam.sh```)(ウェブカメラ搭載システムのみ)
1. 観測データ(ガンマ、HK)やカメラ画像を東京の解析サーバにrsyncするスクリプトのループ実行(```go_rsync_fy2015.sh```)
1. ADCボードの温度をAT&T M2Xクラウドに通知するスクリプトのループ実行(```tell_temp_m2x.sh```)
1. (携帯電話回線の場合) mydnsや解析サーバへIPアドレスを定期的に通知するスクリプト(```tell_ip.sh```)

ロングランを開始するためのスクリプトのサンプルは、```GROWTH-FY2015-Software/scripts/go_longrun.sh```にあります。以下に掲載します。このスクリプトでは、piアカウントのホームディレクトリに```tell_temp_m2x.sh```と```tell_ip.sh```がある場合のみ、M2Xクラウドへの温度データの送信とIPアドレスの通知を実行します。
それ以外の場所にこれらのスクリプトを設置したときは、手動で実行してください。

```sh
#!/bin/bash

# GRWOTH-FY2015
# Long run start up script

PI_HOME=/home/pi
DEV_HDD=/dev/sda1
HDD=/media/hdd
sleepSec=5

#---------------------------------------------
echo "Initial wait ${sleepSec} sec"
sleep ${sleepSec}

#---------------------------------------------
echo "Get detectorID"
detectorID=`growth_config -i`
if [ _$detectorID = _ ]; then
	echo "Error: execute growth_config first."
	exit -1
fi
echo "detectorID = ${detectorID}"

#---------------------------------------------
echo "Mount USB HDD"
sudo mount ${DEV_HDD} ${HDD}

#---------------------------------------------
# check
#---------------------------------------------

# hdd mounted?
if [ ! -d ${HDD}/growth ]; then
	echo "Error: HDD was not properly mouned, or ${HDD}/growth/ folder not found."
	echo "       Check HDD availability as ${DEV_HDD} or otherwise change the path"
	echo "       in the long-run script."
	exit -1
fi

# detector-dependent long-run configuration file
if [ ! -f ${HDD}/growth/data/${detectorID}/configuration_without_wf.yaml ]; then
	echo "Error: ${HDD}/growth/data/${detectorID}/configuration_without_wf.yaml not found."
	echo "        Create a detector-dependent long-run configuration file."
	exit -1
fi

# rsync script
if [ ! -f ${HDD}/go_sync_fy2015.sh ]; then
	echo "Error: ${HDD}/go_sync_fy2015.sh not found."
	echo "       Copy GRWOTH-FY2015-Software/scripts/go_sync_fy2015.sh or create new rsync script."
	exit -1
fi

#---------------------------------------------
echo "Start HK recording"
nohup sudo $PI_HOME/work/install/bin/go_loop_hk.sh &
sleep 5

#---------------------------------------------
echo "Turn on FPGA and high voltage"
echo "FPGA On"
fpga_on
sleep 3
echo "HV On"
hv_on
sleep 3

#---------------------------------------------
echo "Start observation"
cd ${HDD}/growth/data/${detectorID}
nohup sudo $PI_HOME/work/install/bin/go_loop_daq.sh configuration_without_wf.yaml &

#---------------------------------------------
echo "Start rsyncing"
cd ${HDD}
nohup bash go_sync_fy2015.sh &

#---------------------------------------------
if [ -f $PI_HOME/tell_temp_m2x.sh ]; then
	echo "Starting M2X script"
	nohup bash $PI_HOME/tell_temp_m2x.sh &
fi

#---------------------------------------------
if [ -f $PI_HOME/tell_ip.sh ]; then
	echo "Start IP address notification"
	nohup bash $PI_HOME/tell_ip.sh &
fi
```

### M2Xへの通知、IPアドレスの通知

___M2Xクラウドへの通知___

M2Xクラウドへの温度データの通知スクリプト(```tell_temp_m2x.sh```)とdynamic DNSや解析サーバへのIPアドレスの通知スクリプト(```tell_ip.sh```)は、検出器システムに依存したスクリプトとなります。
これらは、```GROWTH-FY2015-Software/scripts/```内に入っているそれぞれのスクリプトのテンプレートを元に、piアカウントの$HOMEディレクトリにコピーして、中身を書き換えて使用してください。

とくにM2Xクラウドについては、デバイスの登録(growth-fy2015x)と、ストリーム(temperature-pcb)の作成を[M2Xのウェブサイト](https://m2x.att.com)上で事前に行ってください。登録が完了すると、デバイスに固有の

- Device ID
- Primary Endpoint
- Primary API Key

が発行されるので、メモしておいてください。これらのID/Keyはデータ通知スクリプトの中に書き込む必要があります。また、チーム内ではDropbox上のファイルで共有→「GROWTH-FY2015-Dropbox/アカウント情報など.text」しているので、このファイルにも追記しておいてください。

テンプレートファイルは```GRWOTH-FY2015-Software/scripts/tell_temp_m2x.sh_template```にあります。これをホームディレクトリにコピーして、ID/Keyを更新して使用してください。

デフォルトでは1分ごとにADCボード上の温度を読みだして、```curl```コマンドでPUTしています。

```sh
#コピー
cp $HOME/work/install/GRWOTH-FY2015-Software/scripts/tell_temp_m2x.sh_template $HOME/tell_temp_m2x.sh
nano $HOME/tell_temp_m2x.sh

#冒頭の以下の部分に、適切なID/Keyを入力する。
deviceID="_________________________"
m2xKey="_________________________"
streamName="temperature-pcb"
```

___IPアドレスの通知___

大学のネットワークを借りられる場合は、IPアドレスが固定になるので、IPアドレスの通知はしなくても良いかもしれません。一方で、携帯電話回線でインターネットに接続する検出器の場合は、回線の再接続によりグローバルIPが変化する可能性があるので、mydns等のdynamic DNSのサービスを用いて対応します。

TBD: dynamic DNSへのIPアドレス通知スクリプトを```GRWOTH-FY2015-Software/scripts/tell_ip.sh_mydns_template```として保存する。

解析サーバへsshでifconfigの結果を通知するスクリプトのテンプレートは```tell_ip.sh_scp_template```として入っています。これを使用する場合は、以下のようにしてください。

```sh
#コピー
cp $HOME/work/install/GRWOTH-FY2015-Software/scripts/tell_ip.sh_scp_template $HOME/tell_ip.sh
nano $HOME/tell_ip.sh
#→ 冒頭のサーバ名を適切に編集
```

### ウェブカメラでの撮影のループ

ウェブカメラで定期的に撮影するスクリプトは、```GRWOTH-FY2015-Software/scripts/go_loop_webcam.sh```にあります。ウェブカメラを接続しているシステムでは、これも

```sh
cd $HOME/work/install/GRWOTH-FY2015-Software/scripts
nohup bash go_loop_webcam.sh &
```

として実行してください。

### ロングランの際に作成されるデータ

ロングラン時の観測データは以下の様なディレクトリ構成、ファイル命名規則で保存されます。

```
構造:
growth/
    data/
        ${detectorID}/
            YYYYMM/
                FITS file
                hk/
                log/
                webcam/

例:
growth/
    data/
        growth-fy2015a/
            201511/
                20151116_165229.fits
                20151116_172233.fits
                ...
                hk/
                    hk_20151116_162002.data
                    hk_20151116_164304.data
                    ...
                log/
                    log_loop_20151116_164312
                    log_loop_20151116_164313
                    ...
                webcam/
                    20151116_164646.jpg
                    20151116_164750.jpg
                    ...
            201512/
            ...
        growth-fy2015b/
        ...
```

rsyncスクリプトの中では、

```sh
rsync -auv growth/data/growth-fy2015* (解析サーバのホスト名):work/growth/data/
```

として、HDDの```growth/data/```以下にある```growth-fy2015*```ディレクトリのデータを解析サーバに伝送します。



