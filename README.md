
## このスクリプトを使うユーザーの前提
* [薬局レセプトシステム　ファーミー](https://www.moinetsystem.com/)を運用している
* [みんなのお薬箱](https://minkusu.jp/usermypage)　
* みんなのお薬箱の自動発注システムを運用している
* 定期的ににファーミーの在庫数値を　みんなのお薬箱　に同期させたい
* 「在庫一覧.txt」と同じディレクトリで、zaiko_txt2csv_for_farmyスクリプトが実行されることを前提に作成しました。

## このスクリプトの目的
* 薬局レセプトシステム　ファーミーが出力した「在庫一覧.txt」をCSVファイルに出力します。

## 運用方法
* 「在庫一覧.txt」と同じディレクトリで、zaiko_txt2csv_for_farmyスクリプトが実行されることを前提に作成してあります。
* 例えば「ファーミー」のような共有ディレクトリを作成し、この[スクリプトを実行可能な状態にして](https://maku77.github.io/mac/command-file.html)保存しておきます。
* ファーミー が出力した「在庫一覧.txt」を、作成した共有ディレクトリに、放り込みます。
* zaiko_txt2csv_for_farmyスクリプトを実行してください。　CSVファイルが同じディレクトリに生成されます。

## rubyスクリプトをダブルクリックで実行可能にするには
* macOS では、シェルスクリプトファイルに .command という拡張子を付けておくと、Finder 上からファイルのアイコンをダブルクリックするだけで起動できるようになります。
* このファイルをダブルクリックで実行できるようにするには、下記のようにします。 chmod +x しておくのを忘れずに。

$ chmod +x zaiko_txt2csv_for_farmy.rb
$ mv zaiko_txt2csv_for_farmy.rb zaiko_txt2csv_for_farmy.command
この仕組みはスクリプトファイルであれば、どんな言語にでも適用できます。 例えば、先頭のシェバング部分を #!/usr/bin/env python などに変更すれば、Python スクリプトをダブルクリックで実行できます。

引用：https://maku77.github.io/mac/command-file.html
