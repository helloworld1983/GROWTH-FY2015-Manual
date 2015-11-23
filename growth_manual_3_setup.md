# 検出器システムのセットアップ

## Raspberry Piのセットアップ

### セットアップ時の構成

- ディスプレイ、キーボード、マウスを接続してください。
- 電源はUSB ACアダプタ(iPadの充電器など)からmicro USBケーブル経由で供給してください。
- セットアップをしているときはADCボードには接続しないでください。

### OSをインストールする

Raspberry Pi用のOSである[Raspbian](https://www.raspberrypi.org/downloads/raspbian/)をダウンロードしてインストールします。RaspbianにはJESSIEとWHEEZYの2種類がありますが、カーネルのバージョンの違いから、ここではWHEEZYを選択します。
ダウンロードしたZIPファイルを

```
unzip 2015-05-05-raspbian-wheezy.zip
```

で解凍します。
Raspberry Piのストレージとして使用するSDカードをPCに挿入し

```
diskutil list
```

とするとPCに接続されているSSD、HDD、SDなどのストレージ情報が表示されます。SDに該当するパス(ここでは/dev/disk2とします)を覚えておきます。

```
diskutil unmountDisk /dev/disk2
```

としてSDをアンマウントします。

```
sudo dd bs=1m if=2015-05-05-raspbian-wheezy.zip of=/dev/rdisk2
```

でSDへ書き込みされます。ここではbs=1mは一度に書き込む値を指定しており、of=/dev/rdisk2 で書き込み先を指定しています。"r"disk2としているのは disk2 にバッファモードで書き込むためのオプションで、これを指定しないと書き込みが非常に遅くなります。書き込みが終了したら

```
diskutil eject /dev/disk2
```

でSDを取り出すことができます。
SDカードをRaspberry Piに挿入し、LANケーブルでMacとRaspberry Piを接続します。microUSBケーブルを挿すと給電され、自動的に電源が入ります。

#### SSHで接続できるようにする

Raspberry PiはHDMIでディスプレイに接続でき、マウスとキーボードを接続することで通常のコンピュータとして使用できますが、ここでは複数台のセットアップを簡略に行うため、最初からSSHのみで動作できるように設定します。
LANケーブルでMacとRaspberry Piが接続されていれば、MacのターミナルよりRaspberry PiにSSHできます。

```
ssh pi@192.168.2.2
```

で接続をトライします。パスワードが求められたら、デフォルトの「raspberry」を入力してログインします。MacとRaspberry Piを直接繋いだ場合、おおよその環境では、Raspberry Piに192.168.2.2のローカルIPが割り当てられるようなので、これでアクセスします。
192.168.2.2でアクセスできない場合は、IPアドレスを検索します。「システム環境設定」->「共有」より「インターネット共有」を選択します。「共通する接続経路」は現在Macがインターネットに接続しているインターフェイス、「相手のコンピュータが使用するポート」でRaspberry PiとMacを接続しているインターフェイスを選択します。インターネット共有を開始することでMacがルーターとなり、Raspberry PiにローカルIPが割り振られます。

```
cat /var/log/system.log | grep OFFER
```

とコマンドを打てば、Raspberry PiのローカルIPアドレスが得られますので、そのアドレスを使ってSSHログインします。

#### OSの初期設定を行う
SSHで初回ログイン後、

```
sudo raspi-config
```

を実行し、初期設定を行います。

- 1 Expand Filesystem
    - 初期設定ではSDカードの容量を全て使用しない設定になっているため、SD全体へ容量を拡張
- 2 Change User Password
    - GROWTH実験用にpiアカウントのパスワードを「*****」に統一して設定します。
    - パスワードは実験メンバーに問い合わせてください。
- 4 Internationalisation Options
    - I2 Change Timezone を選択後、Asia →Tokyo を選んで、時刻をJSTにします。

は必ず実行してください。

___日本語キーボードを接続している場合___

日本語配列のUSBキーボードを接続している場合は、```4 Internationalisation Options```から、

- I3 Change Keyboard Layout → Generic 105-key (Intl) PC → Other → Japanese

とすすんで、変更してください(デフォルトではUK配列)。

___rootでの操作___

Raspberry Piは基本的にSuperUserでの動作が基本なので、ログインしてすぐに

```
sudo su
```

としておくと、以降sudoをつけなくても動作するようになります。

___以下の手順は必要な場合のみ実施してください___

ローカルIPアドレスが変更されるとIPアドレスを毎回さがすことになるため、固定します。
実験室でDHCPで運用しているときは固定する必要はありません。Macとpeer-to-peerで接続して、ローカルIPアドレスで運用したいときは固定してください。

```
nano /etc/network/interfaces
```

を開き、該当箇所を

```
auto eth0
allow-hotplug eth0
iface eth0 inet static
address 192.168.2.2
netmask 255.255.255.0
gateway 192.168.2.1
```

のように書き換えます。これで以降は、同じドメイン内のマシンからは192.168.2.2で接続できます。

### コマンドラインの操作

標準状態ではXWindowは起動しないので、起動直後はCUI(コマンドライン)での操作になります。

GUIを使用したい場合は、piアカウントでログイン後、コマンドラインで

```
startx (リターン)
```

としてXWindowを起動してください。

CUIのまま操作することもできます。Linuxでは、複数のコマンドラインを切り替えながら使用できます。キーボードで```Ctrl+Alt+F1〜F7```を入力すると、それぞれの番号に対応したコマンドラインが表示されます。(複数のターミナルのウインドウを開いているイメージ)

### Raspberry Pi用ソフトウエアのgitレポジトリの取得

まず最初に、GROWTH-FY2015-Softwareという、Raspberry Pi用ソフトウエアのgitレポジトリを取得してください。
このレポジトリには、Raspberry Pi上で動作するDAQソフトウエアに加えて、Raspberry Piのセットアップを自動化するためのスクリプトなどが入っています。
DAQソフトウエアのビルド・インストールは後ほど行います。その前に、以下のセクションで説明するセットアップを実行してください。

```sh
mkdir -p $HOME/work/install
cd $HOME
git clone https://github.com/growth-team/GROWTH-FY2015-Software
```

### apt-getでインストールすべきもの

以下を実行してください。WiFiよりも有線接続のほうが短時間でインストールできます。

```sh
bash $HOME/work/install/GROWTH-FY2015-Software/raspi_setup/install_apt-get.sh
```

### ネットワークの設定

Raspberry Piのデフォルトでは有線LANからDHCPで割り当てられたIPアドレスを使用してインターネットに接続されます。

#### sshサーバの設定(認証鍵でのログイン許可)

___以下の手順は2015年9月にリリースされた、カーネル4以上では実施不要のようです。___

___記述は記録のために残しておきますが、実施しなくてもsshで認証鍵ログインができるようです。___

パスワード入力無しで認証鍵を用いてsshログインできるように、sshサーバ(sshd)の設定を変更します。以下のようにして設定ファイルをエディタで開いて、

```
sudo nano /etc/ssh/sshd_config
```

しばらく下の方に移動すると、```RSAAuthentication```等の項目があるので、以下のように修正してください。

```
RSAAuthentication    yes
PubkeyAuthentication yes
AuthorizedKeysFile   %h/.ssh/authorized_keys
```

編集が完了したら```Ctrl-O → リターン → Ctrl-X```で保存して終了してください。

sshサーバを再起動する必要があるので、

```
sudo /etc/init.d/ssh restart
```

とします。

自分のMacの```id_rsa.pub```の内容をRaspberry Pi上の```$HOME/.ssh/authorized_keys```に追加すれば、パスワード入力無しにssh接続できるようになります。

### Raspberry Piのssh-keyの作成・登録

Raspberry Pi上のpiアカウントから、パスワード無しで東京の解析サーバに
データを送信できるように、Raspberry Pi上にssh-keyを作成し、公開鍵を
東京の解析サーバ内の```~/.ssh/authorized_keys```に登録してください。

```sh
#---------------------------------------------
#Raspberry Pi上での作業
#---------------------------------------------
cd $HOME/.ssh
ssh-keygen
(何回かリターンを入力)

#以下のコマンドで公開鍵のファイルができていることを確認
ls id_rsa.pub

#catで表示して、ターミナルの画面に表示された公開鍵1行分を全て選択→コピー。
cat id_rsa.pub

#---------------------------------------------
#解析サーバ上での作業
#---------------------------------------------

#authorized_keysにRaspberry Piの公開鍵を追加
cat >> $HOME/.ssh/authorized_keys
(Command-Vで先ほどコピーした内容を貼り付ける)
(Control-Dで終了)
```

以上で、解析サーバにパスワード無しでsshログインしたり、rsyncしたりできるようになります。
確認方法は例えば以下のとおり。

```sh
#Raspberry Pi上で
ssh (解析サーバのユーザ名)@(解析サーバのホスト名)
```

### WiFiの設定

実際に観測に使用するRaspberry Piでは、WiFiルータにWiFi経由で接続し、携帯電話回線経由でインターネットに接続できるように設定してください。

#### Wi-Fiドングルのドライバインストール(Raspbian Wheezy (kernel 3.*.*) の場合)
Wi-Fiドングル Planex GW-450D のLinux用ドライバーは[こちら](http://www.planex.co.jp/support/download/gw-450d/driver_linux.shtml)からダウンロードできます。ZIPファイルを解凍し、Raspberry Pi上の```/usr/local/src```にコピーします。

コマンドラインでは以下のようにしてください。

```
mkdir -p $HOME/work/install/wifi
cd $HOME/work/install/wifi
wget http://www.planex.co.jp/support/driver/gw-450d/gw-450d_driver_linux_v3002.zip
unzip gw-450d_driver_linux_v3002.zip
sudo mv gw-450d_driver_linux_v3002/mt7610u_wifi_sta_v3002_dpo_20130916.tar.bz2 /usr/src
```

続いて、

```
uname -r
```

でカーネルのバージョンを確認します。以下のコマンドを実行する際に、___カーネルの部分を適切に書き換える必要があります___。

```
sudo su
#apt-get update
#apt-get -y dist-upgrade
apt-get -y install gcc make bc screen ncurses-dev

cd /usr/src
wget https://github.com/raspberrypi/linux/archive/rpi-3.12.y.tar.gz
tar xfz rpi-3.12.y.tar.gz
ln -s /usr/src/linux-rpi-3.12.y/ /lib/modules/`uname -r`/build
cd /lib/modules/`uname -r`/build
make mrproper
gzip -dc /proc/config.gz > .config
make modules_prepare
wget https://github.com/raspberrypi/firmware/raw/master/extra/Module.symvers
```

途中、```make modules_prepare```コマンド実行時に```[N/m/?]```という選択肢で停止した場合は```m```を選びます。
続いてソースコードを解凍します。

```
cd /usr/local/src
tar xjf mt7610u_wifi_sta_v3002_dpo_20130916.tar.bz2
cd mt7610u_wifi_sta_v3002_dpo_20130916
```

以下のようにして、ソースコードを書き換えます。
まず、

```
nano include/os/rt_linux.h
```

を開いて280~281行目の"int"を"kuid_t"および"kgid_t"に変更して保存します。

```
(変更した結果)
typedef struct _OS_FS_INFO_
{
    kuid_t              fsuid;
    kgid_t              fsuid;
    mm_segment_t    fs;
} OS_FS_INFO;
```

さらに、ドライバのソースコードをGW-450D用に書き換えます。

```
nano common/rtusb_dev_id.c
```

でソースコードを開き、```#endif```の手前に

```
{USB_DEVICE(0x2019,0xab31)}, /* GW-450D */
```

を追加して保存します。

また、次のようにして設定を変更します。

```
nano os/linux/config.mk
```

で設定ファイルを開き、2つのパラメータ

```
HAS_WPA_SUPPLICANT
HAS_NATIVE_WPA_SUPPLICANT_SUPPORT
```

を```n```から```y```に書き換えます。

書き換えができたらmakeします。ここでも適宜カーネルのバージョンを書き換えてください。

```
make
make install
rm -r /etc/Wireless/RT2860STA
mkdir -p /etc/Wireless/RT2870STA
cp RT2870STA.dat /etc/Wireless/RT2870STA/RT2870STA.dat
insmod /lib/modules/`uname -r`/kernel/drivers/net/wireless/mt7650u_sta.ko
```

以上でドライバーのインストールは完了です。

#### Raspbian Jessie (kernel 4.1) の場合

まずカーネルをアップデートします。
```
apt-get update
apt-get dist-upgrade
apt-get install gcc make bc screen ncurses-dev
rpi-update
reboot
```
続いてカーネルのソースをダウンロードしてコンパイルします。
```
cd /usr/src
git clone --depth 1 https://github.com/raspberrypi/linux.git -b rpi-4.1.y
git clone --depth 1 https://github.com/raspberrypi/firmware.git
cd linux
modprobe configs
zcat /proc/config.gz > .config
cp ../firmware/extra/Module7.symvers Module.symvers
make oldconfig
make -j 4 zImage modules dtbs
make modules_install
cp arch/arm/boot/dts/*.dtb /boot/
cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
cp arch/arm/boot/dts/overlays/README /boot/overlays/
cp /boot/kernel7.img /boot/kernel7.img.old
scripts/mkknlimg arch/arm/boot/zImage /boot/kernel7.img
reboot
```
途中、```make oldconfig```コマンド実行時に```[Y/N/m/?]```という選択肢で停止した場合は```m```を選びます。

ドライバーをインストールします。
Wi-Fiドングル Planex GW-450D のLinux用ドライバーは[こちら](http://www.planex.co.jp/support/download/gw-450d/driver_linux.shtml)からダウンロードできます。
ダウンロードしたgw-450d_driver_linux_v3002.zipをRaspberry Pi上の```/usr/src```にコピーします。
以下のコマンドでZIPを解凍し、パッチを当ててソースを書き換え、makeします。

コマンドラインでは以下のようにしてください。

```
sudo su
cd /usr/src
#ドライバソースコードのダウンロード
wget http://www.planex.co.jp/support/driver/gw-450d/gw-450d_driver_linux_v3002.zip
unzip gw-450d_driver_linux_v3002.zip
#ビルドの準備
cd gw-450d_driver_linux_v3002
tar xf mt7610u_wifi_sta_v3002_dpo_20130916.tar.bz2
cd mt7610u_wifi_sta_v3002_dpo_20130916
wget https://raw.githubusercontent.com/neuralassembly/raspi/master/gw-450d/gw-450d-rpi-kernel41.patch
patch -p0 < gw-450d-rpi-kernel41.patch
#ビルド
make
```

途中で、

```
/../../sta/sta_cfg.c:5401:85: error: macro "__DATE__" might prevent reproducible builds [-Werror=date-time]
             snprintf(extra, size, "Driver version-%s, %s %s\n", STA_DRIVER_VERSION, __DATE__, __TIME__ );
                                                                                     ^
/usr/src/gw-450d_driver_linux_v3002/mt7610u_wifi_sta_v3002_dpo_20130916/os/linux/../../sta/sta_cfg.c:5401:95: error: macro "__TIME__" might prevent reproducible builds [-Werror=date-time]
             snprintf(extra, size, "Driver version-%s, %s %s\n", STA_DRIVER_VERSION, __DATE__, __TIME__ );
                                                                                               ^
```

のようなエラーが出てmakeが停止した場合、os/linux/config.mk の冒頭に

```
ccflags-y := -Wno-error=date-time
```

を追記してください。

makeが終わったら、モジュールをインストールします。kernelのバージョンは各自読み替えてください。

```
cp -p os/linux/mt7650u_sta.ko /lib/modules/4.1.6-v7+/kernel/drivers/net/wireless
depmod -a
```

次に、設定ファイルのコピーを行います。

```
mkdir -p /etc/Wireless/RT2870STA
cp RT2870STA.dat /etc/Wireless/RT2870STA/RT2870STA.dat
```

- TBD: WiFiルータへの接続の設定、自動再接続の設定
- TBD: ネットワークインターフェイスの登録(ra0)
- TBD: MyDNSの設定方法(MyDNSへのドメイン名登録、cronによるIPアドレス通知)

### WiFiの接続設定

```
sudo apt-get install -y wicd-curses
```

で設定プログラムをインストール。

```
sudo wicd-curses
```

として起動してください。

初回起動時は、```P```をおして、設定画面を開き

```
無線インターフェース:
有線インターフェース:   eth0
```

のように、無線インタフェースが空欄になっているところを、

```
無線インターフェース:   ra0
有線インターフェース:   eth0
```

として、上の作業で登録したWiFiドングルのインタフェース名を入れてください(インタフェース名は```sudo ifconfig```でも確認できます)。また、下の方にある「再接続する」にチェックが入った状態にしておいてください。保存は```F10```キー(Macの場合はFn+F10)。元の画面に戻るので、```R```を入力。無線LANアクセスポイントの検索が始まり、結果がリストアップされます。

接続先のSSIDを選択して```Enter```。画面に表示される説明に従ってSSIDを選択したり、パスワードを入力してください。

### wiringPiのインストール

GPIO/SPI/I2Cを使用するためのライブラリとして[wiringPi](http://wiringpi.com)を使用します。

___スクリプトによる実行方法___

以下を実行してください。ダウンロードとビルドが実行されます。

```
bash GROWTH-FY2015-Software/raspi_setup/install_wiringPi.sh
```

メッセージの最後に

```
gpio version: 2.29
Copyright (c) 2012-2015 Gordon Henderson
This is free software with ABSOLUTELY NO WARRANTY.
For details type: gpio -warranty

Raspberry Pi Details:
  Type: Model 2, Revision: 1.1, Memory: 1024MB, Maker: Sony [OV]
  Device tree is enabled.
  This Raspberry Pi supports user-level GPIO access.
    -> See the man-page for more details
```

みたいな、バージョン情報が表示されればビルド完了です。

___手作業による実行方法___

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

```
test_readADC
```

を実行してください(DAQソフトウエアのインストールの項を実行すると、このプログラムもビルドされます)。
このプログラムでは、8chのADCが読み出され、画面に表示されます。
温度センサの温度が正常な値になっていない場合は、接触不良の可能性があります。
Raspberry PiがADCボードにちゃんと刺さっているか、ボードのセットアップの項を参照してください。


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

これらの操作はスクリプト化されており、```GROWTH-FY2015-Software/scripts```に入っている以下のスクリプトを実行することでも操作できる。

```
hv_on
hv_off
fpga_on
fpga_off
```

また、ADCボード Version BはRaspberry Piから制御できるLEDを1個搭載しています。
これは、以下のスクリプトで制御できます。

```
led_on
led_off
```

LED onしても、ADCボード上のLED_RPIが点灯しない場合は、Raspberry PiとADCボードの2x20ピンソケットの接触不良の可能性が高いです。この状態ではSlow ADCの読み出し(SPI通信)も正常にできない可能性が高いので、Raspberry Piを一旦取り外し、取り付け手順を再度実行してください。

### DAQソフトウエアのインストール

DAQソフトウエアおよび関連するライブラリは```$HOME/work/install```にインストールします。以下のコマンドを実行してください。

```sh
mkdir -p $HOME/work/install
cd $HOME/work/install

#FY2015の読み出しソフトウエアをダウンロード
git clone https://github.com/growth-team/GROWTH-FY2015-Software
#(推奨)githubアカウントがあれば、
git clone git@github.com:growth-team/GROWTH-FY2015-Software.git

#チェックアウトしたレポジトリの中に入る
cd GROWTH-FY2015-Software

#依存するライブラリをインストール
cd scripts
bash install_libraries.sh
cd ..

#ビルド
cd src
make -f Makefile.pi prepare_external_libs
make -f Makefile.pi -j4
make -f Makefile.pi install
```

これで、```$HOME/work/install/bin```に実行形式がインストールされるので、PATHを通すとプログラムが実行できるようになります(これらは初期設定ファイルに記載してあるので、shの初期設定ファイルを設定していれば自動的にPATHが通っているはずです)。

### 環境設定ファイルのコピーとzshへの変更

zshのほうが何かと効率がよいので、可能なら```chsh```で```/usr/bin/zsh```に標準シェルを変更してください。

GROWTH-FY2015-Softwareのraspi_setupディレクトリには、zshrcが入っているので、$HOME/にリンクすると使いやすいと思います。

```sh
cd $HOME
ln -s $HOME/work/install/GROWTH-FY2015-Software/raspi_setup/zshrc .zshrc
```

.zshrcを編集・更新した場合は、全員にその更新が反映されるように、コミット/pushしておいてください。

```sh
cd $HOME/work/install/GROWTH-FY2015-Software/raspi_setup
#コミット
git commit zshrc -m "変更箇所を説明するメッセージ(英語)"
#github.comに変更をpush
git push origin master
```

### USB HDDのマウント方法

___スクリプトによる実行方法___

以下を実行すると、1度だけ必要な設定が実行される。

```
bash GROWTH-FY2015-Software/raspi_setup/setup_usb_current.sh
```

GROWTH-FY2015-Softwareをビルドしてインストールしていれば、

```
mount_hdd
```

というコマンドを実行するだけで```/media/hdd```にUSB HDDがマウントされます。

___手作業での実行方法___

1. デフォルト設定では、USBポートから供給できる電流が不足し、HDDを接続しても起動しません。
1. USBコネクタから供給できる電流を1.2Aまで増加させるために、```sudo nano /boot/config.txt```で、最後の行に```max_usb_current=1```を追加して再起動。
1. ```sudo mkdir /media/hdd```として、マウントポイントとなるディレクトリを作成。
1. HDDを接続し、```sudo mount /dev/sda1 /media/hdd```としてマウント。/dev/sda1以外の場合は、```sudo dmesg```でどのような名前で検出されたか確認すること。
1. HDD接続中、画面の右上に虹色のアイコンが表示されているときは、電源電圧が4.7V以下に低下しているという知らせ。
  より多く電流を引き出せるUSB ACアダプタ等に接続すること。
1. フォーマット形式がFAT32とかNTFSだと、Raspberry Pi上でファイルのパーミッションを書き換えられなくて不便。
1. もし中身が入っていないHDDなのであれば、Linuxのネイティブフォーマットにしてみてください。
  やりかたは http://frogcodeworks.com/raspberrypi-hdd-format/ を参照。

```
#USB HDDをマウント
sudo mount /dev/sda1 /media/hdd
```

### rsyncスクリプトをコピー

rsyncスクリプトをHDDの直下にコピーしてください。

```sh
sudo cp ~pi/work/install/GROWTH-FY2015-Software/scritps/go_sync_fy2015.sh /media/hdd
```

### growth_config.yamlの作成

ロングラン用のスクリプトが自動的にデータフォルダの位置を見つけられるように、piアカウントのHOMEディレクトリに```growth_config.yaml```という設定ファイルを用意する必要があります。
DAQソフトウエアをインストールすると、このファイルを生成するためのスクリプトも一緒にインストールされているので、以下のコマンドで起動して、ファイルを作成してください。

```sh
> growth_config -g
Generating the configuration file.
Enter detector ID (e.g. growth-fy2015a):
growth-fy2015d                        #←検出器ごとに異なる値を入力
File saved (/home/pi/growth_config.yaml).
```

間違って作成した場合、detectorIDを変更したい場合は、

```sh
nano $HOME/growth_config.yaml
```

としてエディタで開いて直接編集・保存してください。

___重要な注意___

なお、detectorIDは、DAQソフトウエアを実行する際のconfiguration fileにも設定する必要があります(これはFITSファイルのヘッダにIDを記入するため)。
実行時に用意するconfiguration.yamlにも、忘れずにdetectorIDを記入しておいてください。

### ロングラン用ディレクトリの準備

上記の手順でUSB HDDを```/media/hdd```にマウントしておいてください。

```
#HDDをマウント(まだマウントしていなければ)
sudo mkdir /media/hdd
sudo mount /dev/sda1 /media/hdd

#HDDの直下に移動
cd /media/hdd

#GROWTH実験用のフォルダと、dataフォルダを作成
sudo su
mkdir -p growth/data

#検出器ごとのフォルダを作成(以下の例ではfy2015dのフォルダを作成している)
cd growht/data
mkdir growth-fy2015d
```

続いて、このディレクトリに、configuration fileを作成(GROWTH-FY2015-Software/configurationFileからコピーし、編集します。

```
cp $HOME/work/install/GROWTH-FY2015-Software/configurationFile/configuration_abcdefgh.yaml configuration_without_wf.yaml
nano configuration_without_wf.yaml
→detectorIDと、trigger threshold、SamplesInEventPacketなどを適宜調整
→ロングランのときは、SamplesInEventPacketは1に設定して、波形データは残さない
　→イベントパケットのサイズを小さくすることで、ハイレートでもデータ伝送のところで
　イベントが捨てられないようにするため(名称の_without_wfは_without_waveformの略)。
```


## ADCボードのセットアップ

### 用意するもの

- ボードの足として
    - スペーサー × 8個
    - M3ネジ x 8個
- Raspberry Pi固定用
    - 2x20ピンソケット × 1個
    - スペーサ × 4個
    - M3ネジ × 8個

### ADCボードのスペーサ

1. ADCボードの4隅と、中央の4箇所の穴、合計8箇所にスペーサーをM3ネジで取り付ける

### SJ(表面ジャンパ)の設定

___SJ100/101/110/111___

Ch.0/1のアナログ入力をどこに接続するか選択してください。
各SJのハンダ付けと動作モードは以下のとおりです。
詳細は回路図を参照。

|SJ100/SJ110|SJ101/SJ111|動作モード|
|:---:|:---:|:---:|
|1-2        |1-2        |プリアンプ使用|
|2-3        |2-3        |プリアンプ不使用|

___SJ_ADC_MODE___

SJ_ADC_MODEをハンダ付けすると、ADC_MODEを変更できます。
SJ_ADC_MODEをオープンのままにしておくと、ADC内部でADC_MODEはpull downされ、
「Offset binary」+「Duty-ratio stabilizer disabled」という、
雷実験ではフォルトのモードで動作するので、普通はオープンで大丈夫です。

### Version B 2015年10月製造バッチの納品後処置

- 20151029記入。
- C600/C610を実装する
- GPSを実装する
- U520とU302のKSP2222を2SC1815に付け替える(ピン配置非互換だった)

### Raspberry Piの固定

1. Raspberry Piを取り付ける前に、Ch.0/1用の表面ジャンパをハンダ付けする必要がある。上記の手順を参照
1. Raspberry Pi本体側の4隅のネジ穴はM2.6用なので、3.2mmのドリルをつけたボール盤で削って、穴を大きくする
1. スペーサーをADCボードのRaspberry Pi用の穴にネジ止め
1. Raspberry Piのピンヘッダに、2x20のピンソケットを接続
1. スペーサーにRaspberry Piネジ止め(ADCボード側のソケットに刺さる)

### FPGAボードの固定/取り外し

1. FPGAボードを外すときは、FPGAボードに応力をかけたり、ピンヘッダのピンを曲げないように、かなりの注意が必要
1. ADCボードとの間に棒を挟んで、USB miniBコネクタ側と、アナログ入力コネクタ側を交互に、テコの原理で少しずつ浮かせていく
1. とくにFPGAボードが外れる瞬間に力をかけすぎて、ピンヘッダのピンが曲がる場合がある。最後はとくにゆっくり、ADCボードに対して傾かないように(FPGAボードが並行になるように)外していく

### HVモジュールの取り付け

J300およびJ301がHVモジュールの取り付け位置になっている。
2系統はRaspberry PiのHV ON/OFF制御で同時にON/OFFされる。
HV値はVR300とVR301の可変抵抗(20回転する、多回転式の可変抵抗)で設定する(時計回りに回転させるとHV値が増加する)。
HV ONすると、VR_HV0もしくはVR_HV1に、VR300/301の抵抗値に対応した制御電圧がでる。
HV値設定時は、Ch.2/3のLEMOコネクタの隣にある、VR_HV0とVR_HV1の電圧値をモニタしながら可変抵抗を回すこと。

|VR_HV0/HV1の電圧値(V) | HV値(V)|
|:---:|:---:|
|0.59  | 100 |
|1.19  | 200 |
|1.79  | 300 |
|2.39  | 400 |
|2.99  | 500 |
|3.59  | 600 |
|4.17  | 700 |
|4.78  | 800 |
|5.37  | 900 |

パネルマウントのSHVコネクタは、ADCボードを取り付けるインタフェースプレート(アルミ板)にLアングルを立てて、そこに固定すること。HV出力とGNDを、ボード側とコネクタ側で確実にハンダ付けすること。

### SMDジャンパの設定

- TBD: LEMOからの入力をどのように選択するか説明。

### ADC_CM(コモンモード)の設定

- TBD: 抵抗値を変えると変更できることを説明

## 防水ボックスへの組み込み

### 保持ジグ

- TBD: 中野くん製のジグの話を記述

### 配線

- TBD: 電源、ボックス外部の気温・気圧センサへの接続方法
- TBD: ボード上の配線(電源、HV、PMT out)を写真付きで解説
- TBD: 必要なケーブル類のリストを掲載する(USB、自作のケーブル等)
- TBD: メイン／各部分ごとの電源スイッチの用意
- TBD: 無線が使えない状態で筐体内にアクセスできるか？（防水 LAN ケーブル? 他のコネクタ？）


## 観測地での組み上げ手順
(和田さんのメモから編集; TBD 湯浅さんチェック)

- a. 基板をプラスチック筐体板へ設置。ケーブル配線と確認 (TBD: 配線の写真を添付, 配線の順番)

- b. スペーサを設置後のADCボードの初期導通確認(オープン・ショート)確認 (TBD: 写真を追加)
-- 帯電防止リストバンド+導電性シート(GNDプレーン)を定義すること。
-- J301GND-J610+12Vinput ショートしていなければ良い(数百kΩ)
-- GND-J600+12V ショートしていなければ良い(数百kΩ)
-- 電流測定用抵抗とGNDがショートしていないか
-- R500の両端いずれかとGNDがショートしていないか(~3.4kΩ)
-- R510の両端いずれかとGNDがショートしていないか(~1.3kΩ)

- c. Raspberry Pi, Wifi ドングル、FPGA ボード、ADC ボード等の型番の記録

- d. ゲインなどの可変抵抗値(VR)の記録
-- VR100P2 : 
-- VR110P2 : 
-- VR_HV0 : 
-- VR_HV1 : 

- e. 電源投入

-- (i) 入力端子・LED ステータス
--- 電源コネクタ J600_12V(4ピンヘッダ) or J610(DCジャック) 
--- パイロットランプ LED5V ->正常動作・5Vで点灯
--- USBタイプAコネクタ J640(常時5V出力)・J630(RasPiによって出力制御)
--- LED5VSW

-- (ii) 実験室での電源投入
--- 電流リミット12V0.7A —> バナナ - 4ピンケーブルで給電
--- 4ピンコネクタをJ600_12Vに入力
--- 電源投入 --> 電流0.26A・LED5V点灯確認

-- (iii) 観測サイトでの電源投入 (TBD)

- f. HV ケーブルの極性と配線の確認。HV 出力のテスター確認。

- h. データ取得。

- i. 金沢大学などローカルなネットワーク環境をどう記載するか？（TBD)


以上を「手順記録シート(1枚もの)」にしてもよい。
