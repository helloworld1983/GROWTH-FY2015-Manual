# はじめに

このマニュアルでは、GRWOTH FY2015の検出器システムの構成と、ソフトウエアの使い方、
データ解析の流れを説明します。

## 連絡先
このマニュアルは以下のメンバーによって編集されました。
情報のアップデート、誤記などはいかに連絡してください。

- 湯浅孝行 (理化学研究所)
- 榎戸輝揚 (京都大学)
- 和田有希 (東京大学)

## 記入するべきこと(A/Iリスト)
- 各セクションでTBDとなっているところを記述すること(Command+FでTBDで検索)。
- githubのレポジトリ一覧を掲載すること。
    - FPGAロジック
    - DAQソフトウエア
    - データ解析ソフトウエア
    - Raspberry Pi設定・ソフトウエアインストールスクリプト群

## gitレポジトリの一覧

GROWTH FY2015関連のソースコードやテキストはgitレポジトリとしてバージョン管理しています。
このマニュアルに登場するgitレポジトリの一覧をまとめておきます。

レポジトリの中身を編集してgithubにpushするために、あなたのアカウントを[growth-team](https://github.com/growth-team)というorganization accountに登録する必要があります(参照: [organization accountの説明@github](https://git-scm.com/book/ja/v2/GitHub-組織の管理))。
まず、[github](https://github.com)のアカウントを取得して、growth-teamに登録したいアカウント情報を上記の連絡先まで連絡してください。

```
#User manual
git clone git@github.com:growth-team/GROWTH-FY2015-Manual.git

#FPGA VHDL logic
git clone hikari:git/GROWTH-FY2015-FPGA.git
git clone hikari:git/VHDLLibrary.git

#DAQ/Analysis Software
TBD: fill repo address
```
