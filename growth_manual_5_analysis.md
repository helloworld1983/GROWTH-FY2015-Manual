# データ解析の流れ

1. FITSファイルからROOTファイルへの変換
1. 時刻付け
    - GPSモード
    - FPGAフリーランクロックモード
1. ゲイン関数構築
    - 時間分割スペクトルの抽出
    - 環境ガンマ線ラインをフィット
    - ゲイン関数DBファイルを保存
1. エネルギー付け
    - ゲイン関数DBファイルを用いてエネルギー付け
1. エネルギーフィルタリング
1. ライトカーブ作成
1. 時間変動イベント自動抽出
    - エネルギー選別条件、sigma、running averageの幅を変えて

### 時刻付け

注意するべきこと

- PCで記録したunixTimeと、FPGAで記録したtimeTagのドリフトの検証
- GPS HKを持っている場合は、それを使って時刻付けする
- 時刻付の結果をヘッダ情報としてTObjStringで書きだす


### ゲイン関数構築

注意するべきこと

- 複数のファイルから連続的なゲイン関数を構築できるようにする
- フィット結果をプロットしてROOTファイルに保存しておく
    - ひと目でチェックしたり、印刷できるようにしておく
- ラインの場所や強度について、ヒント(フィットの初期値)を外部ファイルで指定できるようにしておく



### 時間変動イベント自動抽出
- 511 keV領域だけに注目してライトカーブを抜き出すとどうなるか
    - e.g. 1秒以下で5シグマ変動しているイベントはあるか、みたいな解析


## HKファイルの解析
### Step 1: FITSファイルへの変換

使用するスクリプト:

```sh
growth_hk_convert_to_fits.rb [HK text file name (comma concatenated for multiple inputs)] [output FITS file name]
```

実行例:

```sh
growth_hk_convert_to_fits.rb \
"hk_20150212_003954.data,hk_20150212_014822.data,hk_20150212_025650.data,hk_20150212_040518.data,
(中略)
hk_20150212_233241.data" hk_20150212.fits
```

### Step 2: プロファイルのプロット
ahQuickLookPlotHK.rbというスクリプトを使用する。

YAML形式の設定ファイルで、プロットしたいFITSのカラム名や軸ラベルを指定すると、
見栄えの良いプロットを生成してくれる。

gitレポジトリが以下から取得可能。

```sh
git clone galaxy.astro.isas.jaxa.jp:/git/common/ahQuickLookPlotHK.git
```

実行には以下のソフトウエアが必要。

- ROOT (Homebrewでインストール)
- RubyFits (Homebrewでインストール)
- RubyROOT (Homebrewでインストール)

```
brew tap yuasatakayuki/hxisgd
brew install root rubyfits rubyroot
```


使用するスクリプト:

```sh
ahQuickLookPlotHK.rb (configuration file) (HK FITS file to be plotted) (output prefix)
```

実行例:

```sh
ahQuickLookPlotHK.rb config_hk_plot_fy2014.yaml hk_20150212.fits hk_20150212
```

上記のコマンドを実行すると、


configuration fileのテンプレートは、

```sh
ahQuickLookPlotHK.rb -g
```

とすると作成されるので、その中身を参照。

たとえば、config_hk_plot_fy2014.yamlの冒頭部分は以下のとおり。

```yaml
temperature:
    type: graph
    title: Temperature/Humidity
    xcolumn: unixTime
    ycolumn: 
        HK/temperature:
            legend: Temp
        HK/humidity:
            legend: Hum
    xlabel: "Time JST"
    ylabel: "Temperature degC / Humidity %"
    yrange: -10 80
    options:
        skip: 10
        time_in_unixtime: yes
        time_zone: JST

command:
    type: graph
    title: Command Receive Counter / Status
    xcolumn: unixTime
    ycolumn: 
        HK/receiveCounter:
            legend: Receive Counter
        HK/commandID:
            legend: Command ID
        HK/commandStatus:
            legend: Status
    xlabel: "Time JST"
    ylabel: "Counter value"
    #yrange: -1 20
    options:
        skip: 10
        time_in_unixtime: yes
        time_zone: JST
```

### プロットの結合
上記の例で生成されるall PDFを、1枚にまとめて印刷したいときは以下のコマンドを実行する。

事前に[Mac TeX](https://tug.org/mactex/)をインストールしておく必要がある。

```
pdfnup --nup 2x3 --suffix '2x3' hk_20150212_all.pdf
open hk_20150212_all_2x3.pdf
```
