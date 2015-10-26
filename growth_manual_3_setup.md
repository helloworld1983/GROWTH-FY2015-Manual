# 検出器システムのセットアップ

## Raspberry Piのセットアップ

### セットアップ時の構成

- ディスプレイ、キーボード、マウスを接続してください。
- 電源はUSB ACアダプタ(iPadの充電器など)からmicro USBケーブル経由で供給してください。
- セットアップをしているときはADCボードには接続しないでください。

### OSをインストールする

- TBD: Raspbianのインストール方法、初期設定方法を記入する。
- TBD: GROWTH実験で使うRaspberry Piはアカウント/パスワードを統一する。

### コマンドラインの操作

標準状態ではXWindowは起動しないので、起動直後はCUI(コマンドライン)での操作になります。

GUIを使用したい場合は、piアカウントでログイン後、コマンドラインで

```
startx (リターン)
```

としてXWindowを起動してください。

CUIのまま操作することもできます。Linuxでは、複数のコマンドラインを切り替えながら使用できます。キーボードで```Ctrl+Alt+F1〜F7```を入力すると、それぞれの番号に対応したコマンドラインが表示されます。(複数のターミナルのウインドウを開いているイメージ)


### apt-getでインストールすべきもの

以下をコピーペーストして実行してください。WiFiよりも有線接続のほうが短時間でインストールできます。

```sh
sudo apt-get update
sudo apt-get install -y fswebcam 
sudo apt-get install -y git dpkg-dev make g++ gcc binutils 
sudo apt-get install -y libx11-dev libxpm-dev libxft-dev libxext-dev python-dev
sudo apt-get install -y gfortran ruby ruby-dev rails wget curl curl-dev zsh
sudo apt-get install -y build-essential curl m4 texinfo libbz2-dev
sudo apt-get install -y libcurl4-openssl-dev libexpat-dev libncurses-dev
sudo apt-get install -y zlib1g-dev chromium libx11-dev gcc-4.8 g++-4.8
sudo apt-get install -y apache2 php5 php5-mysql php5-curl php5-gd mysql-server
sudo apt-get install -y imagemagick libjpeg8-dev
sudo apt-get install -y git cmake swig subversion
sudo apt-get install -y gcc-4.8 g++-4.8 libboost1.50-all libxerces-c-dev
```

### ネットワークの設定

Raspberry Piのデフォルトでは有線LANからDHCPで割り当てられたIPアドレスを使用してインターネットに接続されます。

#### sshサーバの設定(認証鍵でのログイン許可)

パスワード入力無しで認証鍵を用いてsshログインできるように、sshサーバ(sshd)の設定を変更します。以下ようにして設定ファイルをエディタで開いて、

```
sudo nano /etc/ssh/sshd_config
```

- TBD: ここにsshd_configの設定方法を追記
- TBD: ~/.ssh/authorized_keysとconfigの記述(サーバー名を簡略化できるように)

実際に観測に使用するRaspberry Piでは、WiFiルータにWiFi経由で接続し、携帯電話回線経由でインターネットに接続できるように設定してください。

- TBD: WiFiドングルの設定、WiFiルータへの接続の設定、自動再接続の設定
- TBD: MyDNSの設定方法(MyDNSへのドメイン名登録、cronによるIPアドレス通知)


### wiringPiのインストール

GPIO/SPI/I2Cを使用するためのライブラリとして[wiringPi](http://wiringpi.com)を使用します。
以下のようにしてダウンロード・インストールしてください。

```sh
mkdir -p $HOME/work/install
cd $HOME/work/install
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

#check build
gpio -v
```

### USB HDDのマウント方法
1. デフォルト設定では、USBポートから供給できる電流が不足し、HDDを接続しても起動しません。
1. USBコネクタから供給できる電流を1.2Aまで増加させるために、```sudo nano /boot/config.txt```で、最後の行に```max_usb_current=1```を追加して再起動。
1. ```sudo mkdir /media/hdd```として、マウントポイントとなるディレクトリを作成。
1. HDDを接続し、```sudo mount /dev/sda1 /media/hdd```としてマウント。/dev/sda1以外の場合は、```sudo dmesg```でどのような名前で検出されたか確認すること。
1. HDD接続中、画面の右上に虹色のアイコンが表示されているときは、電源電圧が4.7V以下に低下しているという知らせ。
  より多く電流を引き出せるUSB ACアダプタ等に接続すること。
1. フォーマット形式がFAT32とかNTFSだと、Raspberry Pi上でファイルのパーミッションを書き換えられなくて不便。
1. もし中身が入っていないHDDなのであれば、Linuxのネイティブフォーマットにしてみてください。
  やりかたは http://frogcodeworks.com/raspberrypi-hdd-format/ を参照。

### SPI通信をenableする
HK収集用のスローADCは、Raspberry PiとSPIインタフェースで接続されています。
デフォルト状態ではSPI通信は許可されていないので、以下の手順で許可してください。

コマンドラインで

```sh
sudo raspi-config
```

として設定プログラムを起動し、

```sh
8 Advanced Options
→ A5 SPI Enable/Disable automatic loading of SPI kernel module
```

で有効にする。設定後、再起動必要。

電源投入後、初回は
```
gpio load spi
```
として、wiringPiのSPIモジュールをロードする必要があります。

SPI通信でADCが読めるかどうかの試験は、

```sh
test_readADC
```

を実行する。8chのADCが読み出され、画面に表示される。
温度センサの温度が正常な値になっていない場合は、接触不良の可能性がある。
Raspberry PiがADCボードにちゃんと刺さっているか確認すること。


### GPIOによるHV電源/5V電源の制御
#### Version Aボード
Raspberry Piのコマンドラインから
```
#出力方向の設定
gpio mode 27 out
#HV 12V on
gpio write 27 1
```
とするとHV用のMOSFETがONして、HVの電源に12Vが供給される。

#### Version Bボード
Raspberry Piのコマンドラインから
```
#出力方向の設定
gpio mode 27 out
gpio mode 26 out

#HV 12V on
gpio write 27 1
#HV 12V off
gpio write 27 0

#FPGA 5V on
gpio write 26 1
#FPGA 5V off
gpio write 26 0
```
とすると、HV用12V、FPGA用5VがそれぞれON/OFFできる。

### DAQソフトウエアのインストール

DAQソフトウエアおよび関連するライブラリは```$HOME/work/install```にインストールします。以下のコマンドを実行してください。

```
TBD: setupスクリプトの実行方法を記述する。
```


## ADCボードのセットアップ

- TBD: FPGAボード、Raspberry Piの接続方法、HVモジュールとSHVコネクタの取り付け方法
- TBD: ボード上の配線(電源、HV、PMT out)を写真付きで解説
- TBD: 必要なケーブル類のリストを掲載する(USB、自作のケーブル等)

### SMDジャンパの設定

- TBD: LEMOからの入力をどのように選択するか説明。

### ADC_CM(コモンモード)の設定

- TBD: 抵抗値を変えると変更できることを説明

## 防水ボックスへの組み込み

### 保持ジグ

- TBD: 中野くん製のジグの話を記述

### 配線

- TBD: 電源、ボックス外部の気温・気圧センサへの接続方法

