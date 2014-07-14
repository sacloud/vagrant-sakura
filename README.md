# Vagrant Sakura Provider

[![Gem Version](https://badge.fury.io/rb/vagrant-sakura.png)](http://badge.fury.io/rb/vagrant-sakura)

この gem は [Vagrant](http://www.vagrantup.com) に
[さくらのクラウド](http://cloud.sakura.ad.jp)上のサーバを操作する
機能を追加する provider です。

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
$ vagrant box add dummy https://github.com/tsahara/vagrant-sakura/raw/master/dummy.box
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
    sakura.access_token = 'YOUR ACCESS TOKEN'
    sakura.access_token_secret = 'YOUR ACCESS TOKEN SECRET'
    sakura.use_insecure_key = true
  end
end
```

そして ``vagrant up --provider=sakrua`` を実行してください。

サーバのディスクソースを ``sakura.disk_source_archive`` で指定しなかった
場合のデフォルトは ``112500182464`` で Ubuntu 12.04.2LTS-server 64bit です。
このディスクソースのログインアカウントは ``root`` ではないため、
``config.ssh.username`` で指定してやる必要があります。

なお、さくらのクラウド API を利用するための API キー(ACCESS TOKEN)と
シークレットトークン(ACCESS TOKEN SECRET)は環境変数
``SAKURA_ACCESS_TOKEN`` と ``SAKURA_ACCESS_TOKEN_SECRET``で指定することも
できます。

## SSH 鍵の指定方法

vagrant-sakura では、サーバにログインするための SSH 公開鍵を 3通りの方法で
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
`sakura-list-id` コマンドを使って、`Vagrantfile` で指定するリソース ID
を調べることができます。
```
$ vagrant sakuara-list-id
...
```

## 設定

さくらのクラウド provider では以下の設定ができます:

- ``access_token`` - さくらのクラウド API にアクセスするための API キー
- ``access_token_secret`` - API キーのシークレットトークン
- ``disk_plan`` - サーバで利用するディスクのプラン ID
- ``disk_source_archive`` - サーバで利用するディスクのベースとするアーカイブ
- ``server_name`` - サーバ名
- ``server_plan`` - 作成するサーバのプラン ID
- ``sshkey_id`` - サーバへのログインに利用する SSH 公開鍵のリソース ID
- ``zone_id`` - ゾーン ID (石狩第1=`is1a`, 石狩第2=`is1b`)

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
