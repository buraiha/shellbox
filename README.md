# ShellBoxについて

![ShellBox_Logo](./ShellBox_Logo_Title.png)

「ホストを守るのは、ShellBoxじゃない。あなたです。」

ホストOS環境潔癖症の皆様に捧ぐ。

「ホストOSをいかに汚さずにコマンドを発行するか」を突き詰めた仕組み。

ツールというより、考え方、概念、そして精神衛生を保つための心がけ。

ShellBoxとは、そんな「思想」です。

## 全てはコンテナで

とにかくホストOSの環境を汚したくないのです。

macOSを普段使っていますが、サードパーティーのツールを使うときはmacportsとかbrewとかを使いますが、昔環境を激しく壊してしまった経験があり、ホストOS環境保全になってしまった次第です。

先日もazure cliをmacportsで入れようとしたら、macportsにazule cliは存在はするけどまともに動かなくて、やむなくbrewも入れる、、、という羽目になりました。portsもbrewも共存できるので問題はないのですが、やっぱり気持ち悪いのです。わかりますかねこの気持ち。

dockerやpodmanを使うと、ホストOSの環境を汚さずにコマンドを実行できるので、非常に精神衛生上よろしいです。

## ShellBoxの仕組み

ShellBoxは、実行コマンド・構成情報・依存関係・前提条件などを一つに「カプセル化」した再利用可能なシェル操作ユニットです。

やってることは簡単で、呼び出すメインのコマンドの実行環境をコンテナに封じ込めて、ローカルのディレクトリをマウントして、コンテナ内で処理するだけです。当然ですが、ローカルディレクトリの内容を変更するようなコマンドは、そのディレクトリをマウントする必要があります。

以下にlsを例にとって説明しているので[Dockerfileの例](#dockerfileの例)、勝手はわかるかとおもいます。

Dockerfile内のENTRYPOINTが実行される形になるので、run コマンドで引数を渡してカプセル化したバイナリを実行することができます。

## おすすめコンテナランタイム

podmanをおすすめします。Dockerでもよいですが、podmanのほうが好きだからです。ロゴにもセルキーが入っている手前もありますし。

podmanのほうがrootlessで動かせるので、セキュリティ的にも安心です(今日びのDockerでもできますけどね)。とくにこの仕組みのは細かいツールをたくさんコンテナ化する形になるので、変なことをしてrm -rf なんぞをしてしまっても安心。

## おすすめBase Image

distrolessがイメージ容量が小さいのでおすすめ。

debugタグのイメージでないと、busiboxが入っていないので、catやlsなどのコマンドが使えない。軽量ゆえに、不要なものは入っていません。

その他、java入りやpython入りのイメージもあるので、使い勝手が良いやつを使うとよいです。

[distroless利用できるイメージ一覧](https://github.com/GoogleContainerTools/distroless?tab=readme-ov-file#what-images-are-available)

タグはrootでもnonrootどちらでも良いですが、nonrootのほうがセキュリティ高めです。

インストール用スクリプトも、podmanを前提にして作成しています。Dockerを使う場合は、適宜書き替えてください。

### Dockerfileの例

lsやcat等の基本的なコマンドを使うためのDockerfileは以下の通り簡単なものです。

```Dockerfile
# ベースイメージ
FROM gcr.io/distroless/base-debian12:debug-nonroot
ENTRYPOINT ["ls"]
```

ShellBoxの実行

```sh
# イメージのビルド
podman build -t shellbox_ls .
# コンテナの実行
podman run --rm -v $PWD:/mnt shellbox_ls /mnt
```

---

pythonの処理系を整備して使いたい場合は、以下のような感じです。

```Dockerfile
# ベースイメージ
FROM gcr.io/distroless/python3-debian12:debug-nonroot

# その他の必要なパッケージをインストール

# ENTRYPOINTを設定
ENTRYPOINT ["python3"]
```

test_script.py

```python
print("Hello, ShellBox!")
```

ShellBoxの実行

```sh
# イメージのビルド
podman build -t shellbox_python .
# コンテナの実行
podman run --rm -v $PWD:/mnt shellbox_python /mnt/test_script.py
```

## 今後の展開

- /usr/local/shellbox/bin の中に実行スクリプトを配備し、そのスクリプトから podman run するような仕組みを作る。
  - そのスクリプトをPATHに通しておくことで、どこからでも実行できるようにする。
- 上のように/usr/local/shellbox/bin の中に、作成したShellBoxコマンドを自動で格納するしくみ(install)を作成する。
