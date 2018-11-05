# Vagrant Sakura Provider

[![Gem Version](https://badge.fury.io/rb/vagrant-sakura.png)](http://badge.fury.io/rb/vagrant-sakura)
[![Build Status](https://travis-ci.org/sacloud/vagrant-sakura.svg?branch=master)](https://travis-ci.org/sacloud/vagrant-sakura)
[![Slack](https://slack.usacloud.jp/badge.svg)](https://slack.usacloud.jp/)  

この gem は [Vagrant](http://www.vagrantup.com) に
[さくらのクラウド](http://cloud.sakura.ad.jp)上のサーバを操作する
機能を追加する provider です。

> __*このリポジトリは[tsahara/vagrant-sakura](https://github.com/tsahara/vagrant-sakura)から移行されました。*__

## 機能 / 制限

* さくらのクラウド上にサーバを作成できます。
* サーバに SSH ログインできます。
* サーバを停止/再開(オフ/オン)できます。
* Chef をはじめとする provisioner が動きます。

なお Chef を利用する場合は `vagrant-omnibus` プラグインを使ってサーバ上に
Chef をインストールしてください。

## インストール

通常の Vagrant 1.1+ 以降のプラグインの導入方法でインストールできます。
インストール後は `sakura` プロバイダを指定して `vagrant up` してください。
以下に例を示します:

```
$ vagrant plugin install vagrant-sakura
...
$ vagrant up --provider=sakura
...
```

なお実行前にさくらのクラウド用の Vagrant box を取得しておく必要があります。

## かんたんな使い方

プラグインを(先述の通りに)インストールしたら、てっとり早く始めるためには
ダミーのさくらのクラウド用 box を使い、詳細は `config.vm.provider` で
指定します。
まずはじめに、ダミーの box を好きな名前で追加してください:

```sh
$ vagrant box add dummy https://github.com/sacloud/vagrant-sakura/raw/master/dummy.box
...
```

次に、以下のような Vagrantfile を作成し、必要な情報を埋めてください。
**なお、以下の Vagrantfile は Vagrant 付属の "insecure key" でログインできる
サーバを作成します。実用する際は次節の「SSH 鍵の指定方法」を参考に安全な
SSH 鍵を設定してください。**

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.username = "ubuntu"

  config.vm.provider :sakura do |sakura|
    sakura.access_token = '<YOUR ACCESS TOKEN>'
    sakura.access_token_secret = '<YOUR ACCESS TOKEN SECRET>'
    sakura.use_insecure_key = true
  end
end
```

そして ``vagrant up --provider=sakura`` を実行してください。

サーバのディスクソース(OS)は ``sakura.disk_source_archive`` または``sakura.os_type``で指定します。  
デフォルトでは``sakura.os_type="ubuntu"``となっています。

> 注: ディスクソースに指定するOSに応じて`config.ssh.username`を適切に指定する必要があります。  
詳細は`os_type`の説明を参照してください。

## APIキーの指定

さくらのクラウド API を利用するための APIキー(トークン/シークレット/ゾーン)は 以下の3通りの方法で指定できます。

 1. Vagrantfileに直接記載
 2. さくらのクラウド CLI [Usacloud](https://github.com/sacloud/usacloud)の設定ファイル
 3. 環境変数

> 複数指定されている場合はより上に記載されているものが優先されます。

### 1. Vagrantfileに直接記載

以下のようにVagrantfileに直接記載する方法です。

```Ruby
  config.vm.provider :sakura do |sakura|
    sakura.access_token = '<YOUR ACCESS TOKEN>'
    sakura.access_token_secret = '<YOUR ACCESS TOKEN SECRET>'
    sakura.zone_id = '< is1a / is1b / tk1a >'
    
    # ...
  end
```

### 2. さくらのクラウド CLI Usacloudの設定ファイル

[Usacloud](https://github.com/sacloud/usacloud)の設定ファイルを利用する方法です。  
UsacloudにてAPIキーの設定(`usacloud config`コマンドの実行など)を行なっておけばvagrant-sakura が自動的にUsacloudの設定ファイルを読み込みます。
この機能を利用すればVagrantfileにAPIキー関連の設定を記載する必要はありません。

デフォルトでは`~/.usacloud/<current_profile>/config.json`ファイルが利用されます。  
任意のUsacloud設定ファイルを利用したい場合、Vagrantfileに`config_path`を指定することで利用する設定ファイルを指定できます。

```Ruby
  config.vm.provider :sakura do |sakura|
    sakura.config_path = 'your/config/file.json'
    # ...
  end
```

### 3. 環境変数

環境変数でAPIキーを指定可能です。  
Usacloudや[Packer for さくらのクラウド](https://github.com/sacloud/packer-builder-sakuracloud)、[Terraform for さくらのクラウド](https://github.com/sacloud/terraform-provider-sakuracloud)と共通の環境変数を利用できます。  

- API アクセストークン: `SAKURACLOUD_ACCESS_TOKEN` または `SAKURA_ACCESS_TOKEN`
- API シークレット: `SAKURACLOUD_ACCESS_TOKEN_SECRET` または `SAKURA_ACCESS_TOKEN_SECRET`
- ゾーン: `SAKURACLOUD_ZONE`

## SSH 鍵の指定方法

vagrant-sakura では、サーバにログインするための SSH 公開鍵を 以下の3通りの方法で
設定できます。

 1. コントロールパネルで設定済みの SSH 公開鍵をリソース ID で指定する。
    対応する秘密鍵は ``override.ssh.private_key_path`` で指定できます。
    ```
    sakura.sshkey_id = '101234567890'
    override.ssh.private_key_path = File.expand_path("~/.ssh/vagrant")
    ```

 2. SSH 公開鍵のパスを指定する。この方法では、ひとつサーバを作成する度に SSH
    公開鍵リソースがひとつ作成されます。vagrant-sakura が SSH 公開鍵リソース
    を削除することはないため、SSH 公開鍵リソースが不必要に増えてしまうことに
    注意が必要です。
    ```
    sakura.public_key_path        = File.expand_path("~/.ssh/vagrant.pub")
    override.ssh.private_key_path = File.expand_path("~/.ssh/vagrant")
    ```

 3. Vagrant 付属の "insecure key" をそのまま使う。"insecure key" は安全性に
    懸念があるため、``sakura.use_insecure_key`` を `true` にセットした時に
    のみ利用されます。
    ```
    sakura.use_insecure_key = true
    ```


## コマンド

#### OSの再インストール

`sakura-reinstall` コマンドを使って、ディスクに対しOSの再インストールを行うことができます。

```
$ vagrant sakura-reinstall
...
```

#### 各種IDの一覧表示

`sakura-list-id` コマンドを使って、`Vagrantfile` で指定するリソース ID
を調べることができます。
```
$ vagrant sakura-list-id
...
```

## 設定

さくらのクラウド provider では以下の設定ができます:

- ``access_token`` - さくらのクラウド API にアクセスするための API キー
- ``access_token_secret`` - API キーのシークレットトークン
- ``disk_plan`` - サーバで利用するディスクのプラン ID
- ``os_type`` - サーバで利用するディスクのベースとするアーカイブの種別 (※ `disk_source_archive`とは同時に指定できません)  
指定可能な値は以下の通りです。  

|指定可能な値|SSHユーザー名|Vagrantfileの例|備考|
|---|---|:---:|---|
|`ubuntu`(デフォルト)|`ubuntu`| [example](examples/ubuntu.md) | - |
|`ubuntu-18.04`|`ubuntu`| - | - |
|`ubuntu-16.04`|`ubuntu`| - | - |
|`centos`|`root`| [example](examples/centos.md) | - |
|`centos6`|`root`| [example](examples/centos6.md) | - |
|`debian`|`root`| [example](examples/debian.md) | - |
|`coreos`|`core`| [example](examples/coreos.md) | - |
|`freebsd`|`root`| [example](examples/freebsd.md) | - |
|`rancheros`|`rancher`| [example](examples/rancheros.md) | メモリ2GB以上のプランが必要 |

- ``disk_source_archive`` - サーバで利用するディスクのベースとするアーカイブのID (※`os_type`とは同時に指定できません)
- ``server_name`` - サーバ名
- ``server_plan`` - 作成するサーバのプラン ID(**非推奨** 代わりに`server_core`と`server_memory`を利用してください)
- ``server_core`` - 作成するサーバのコア数(デフォルト: `1`)
- ``server_memory`` - 作成するサーバのメモリサイズ(GB単位、デフォルト: `1`)
- ``packet_filter`` - 作成するサーバに適用するパケットフィルタ ID
- ``startup_scripts`` - 作成するサーバに適用するスタートアップスクリプト ID(リスト)
- ``enable_pw_auth`` - パスワード認証の有効化(デフォルト: `false`)
- ``tags`` - 作成するサーバ/ディスクのタグ(リスト)
- ``description`` - 作成するサーバ/ディスクの説明
- ``sshkey_id`` - サーバへのログインに利用する SSH 公開鍵のリソース ID
- ``zone_id`` - ゾーン ID (石狩第1=`is1a`, 石狩第2=`is1b`、東京第1=`tk1a`、デフォルトは`is1b`)
- ``config_path`` - APIキーが記載されたUsacloud設定ファイルのパス

## ネットワーク
``vagrant-sakura`` は ``config.vm.network`` を利用したネットワークの構築を
まだサポートしていません。

## 開発

``vagrant-sakura`` プラグインをいじる場合は、リポジトリを clone してから
[Bundler](http://gembundler.com/) を使って依存関係を解決してください。
```sh
$ bundle
```
依存パッケージが入ったら、。。。
開発を始められます。
``Vagrantfile`` を clone したディレクトリに置いて
(.gitignore に書いてあるので git には無視されます)、
以下の行を ``Vagrantfile`` に足してやれば、プラグインをインストールしなくても
開発中の Vagrant 環境をテストすることができます。
```Ruby
Vagrant.require_plugin "vagrant-sakura"
```

Vagrant を実行する時は bundler を使ってください:
```sh
$ bundle exec vagrant up --provider=sakura
```
