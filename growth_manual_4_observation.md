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

### 観測時のループ実行

- TBD: 観測用スクリプトの実行方法を記述する。
- TBD: rsync用スクリプトの実行方法を記述する。

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
|timeTag|K|-|int64_t|FPGAローカルクロックのtime tag(48bit; 20ns刻み)|
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

|TTYPE|TFORM|TZERO|データ型|FPGAローカルクロック(48bit; 20ns刻み)|
|:---:|:---:|:---:|:---:|:---|
|timeTag|K|-|int64_t|FPGAローカルクロックのtime tag(48bit; 20ns刻み)|
|gpsTime|20A|-|char[20]|GPSのYYMMDD HH:MM:SS|
|unixTime|J|2147483648|uint32_t|Raspberry Pi上のUNIX Time|

