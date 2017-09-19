# cmd_status_wait

## 概要

コマンド実行結果が期待状態になるまで待機

## 使用方法

### cmd_status_wait.sh

ローカルホストにおけるコマンド実行結果が期待状態になるまで待機します。

    $ cmd_status_wait.sh "コマンドラインの期待結果" "コマンドライン"

リモートホストにおけるコマンド実行結果が期待状態になるまで待機します。

    $ cmd_status_wait.sh -H リモートホスト名 "コマンドラインの期待結果" "コマンドライン"

### その他

* 上記で紹介したツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* openssh (「-H オプション」を使用する場合のみ)
* [common_sh](https://github.com/yuksiy/common_sh)
* [color_tools](https://github.com/yuksiy/color_tools)

## インストール

ソースからインストールする場合:

    (Linux, Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/cmd_status_wait>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/cmd_status_wait/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2011-2017 Yukio Shiiya
