> 🌍 English version available: [README.en.md](./README.en.md)

# ShellBoxについて

![ShellBox_Logo](./ShellBox_Logo_Title.png)

「ホストを守るのは、ShellBoxじゃない。あなたです。」

ホストOS環境潔癖症の皆様に捧ぐ。

「ホストOSをいかに汚さずにコマンドを発行するか」を突き詰めた仕組み。

ツールというより、考え方、概念、そして精神衛生を保つための心がけ。

「人とマシンの心身を、汚さぬために。ShellBox。」

---

## 全てはコンテナで

とにかくホストOSの環境を汚したくないのです。

macOSで開発する際、HomebrewやMacPortsなどでツールをインストールすることが多いですが、過去に環境を壊してしまった経験から、現在は環境保全を最優先に考えています。

先日もazure cliをmacportsで入れようとしたら、macportsにazule cliは存在はするけどまともに動かなくて、やむなくbrewも入れる、、、という羽目になりました。portsもbrewも共存できるので問題はないのですが、やっぱり気持ち悪いのです。わかりますかねこの気持ち。

dockerやpodmanを使うと、ホストOSの環境を汚さずにコマンドを実行できるので、非常に精神衛生上よろしいです。

---

## ShellBoxの仕組み

ShellBoxの仕組み

ShellBoxは、特定のコマンドをコンテナ内で実行可能にするカプセル化ユニットです。

- 各コマンドごとに専用のコンテナイメージを作成
- ローカルの作業ディレクトリを /mnt にマウント
- podman run により、コンテナからホストのデータを操作

これにより、環境を汚すことなくツールを再利用・共有できます。

---

## おすすめコンテナランタイム

podmanをおすすめします。Dockerでもよいですが、podmanのほうが好きだからです。ロゴにもpodmanのセルキーが入っている手前もありますし。

podmanのほうがrootlessで動かせるので、セキュリティ的にも安心です(今日びのDockerでもできますけどね)。とくにこの仕組みのは細かいツールをたくさんコンテナ化する形になるので、変なことをしてrm -rf なんぞをしてしまっても安心。

---

## おすすめBase Image

distrolessがイメージ容量が小さいのでおすすめ。

debugタグのイメージでないと、busiboxが入っていないので、catやlsなどのコマンドが使えない。軽量ゆえに、不要なものは入っていません。

その他、java入りやpython入りのイメージもあるので、使い勝手が良いやつを使うとよいです。

[distroless利用できるイメージ一覧](https://github.com/GoogleContainerTools/distroless?tab=readme-ov-file#what-images-are-available)

タグはrootでもnonrootどちらでも良いですが、nonrootのほうがセキュリティ高めです。

インストール用スクリプトも、podmanを前提にして作成しています。Dockerを使う場合は、適宜書き替えてください。

---

## Dockerfileの例

### 基本コマンド（例: `ls`）

```Dockerfile
FROM gcr.io/distroless/base-debian12:debug-nonroot
ENTRYPOINT ["ls"]
```

```sh
podman build -t shellbox_ls .
podman run --rm -v "$PWD":/mnt shellbox_ls /mnt
```

### Pythonスクリプト実行例

```Dockerfile
FROM gcr.io/distroless/python3-debian12:debug-nonroot
ENTRYPOINT ["python3"]
```

```python
# test_script.py
print("Hello, ShellBox!")
```

```sh
podman build -t shellbox_python .
podman run --rm -v "$PWD":/mnt shellbox_python /mnt/test_script.py
```

---

## ShellBoxの使い方

### インストール

以下のコマンドでShellBoxをインストールします。

```sh
curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/lib/install.sh | bash
```

再インストールしたい場合：

```sh
curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/lib/install.sh | bash -s -- --force
```

## 🧪 ShellBoxコマンドの基本機能

`shellbox` は、ShellBox環境全体を管理するためのCLIツールです。以下のような機能を提供しています。

| コマンド                                                 | 説明                                                            |
| ---------------------------------------------------- | ------------------------------------------------------------- |
| `shellbox init`                                      | ShellBoxの基本ディレクトリ構成を初期化します（`bin`, `log`, `containers` などを作成）。 |
| `shellbox install \<name\> \<entrypoint\> [image] [-f \| --force]`                                                    | 指定された ENTRYPOINT とイメージでコマンドをShellBox化し、スクリプトを `/usr/local/shellbox/bin/<name>` に生成します。<br> `image` を省略した場合は `gcr.io/distroless/base-debian12:debug-nonroot` が使用されます。<br> `--force` を指定すると ENTRYPOINT 存在チェックをスキップします。 <br>※デフォルトのコンテナイメージはdistrolessを使っており、lsやcutなどのコマンドはbusyboxに含まれるため、ENTRYPOINT存在チェックで存在を検知できません。そういったコマンドを使用するときには`--force`してください。|
| `shellbox uninstall`                                 | ShellBox本体を削除するためのスクリプト（`lib/uninstall.sh`）を呼び出します。           |
| `shellbox -e <name>`                                 | 指定したShellBoxスクリプトを `$EDITOR` または `vi` で開きます。                  |
| `shellbox -l`                                        | インストール済みのShellBoxコマンド一覧を表示します。                                |
| `shellbox -r <name>`                                 | 指定したコマンドに関連するスクリプトとDockerfileを削除します。                          |
| `shellbox --path`                                    | ShellBoxが使用している構成ディレクトリのパスを一覧表示します。                           |
| `shellbox --version`                                 | ShellBoxのバージョン（`/usr/local/shellbox/VERSION`）を表示します。          |

---

## 🧭 /mnt = ShellBoxにおける論理的な作業ディレクトリ

ShellBoxでは、ホスト上の作業ディレクトリ（例：`$PWD`）を原則として `/mnt` にマウントします。

これは単なる技術的都合ではなく、**ShellBoxにおける「論理的な作業ディレクトリ」**という思想的な位置づけです。

- ホスト環境を一切汚さない
- 明示的なマウントにより操作対象を限定する
- `/mnt` を前提に設計することで、スクリプトの移植性が高まる

---

## 🧩 追加マウントの定義（mounts.conf）

ShellBoxでは、特定のコマンドに対して追加のマウントを行いたい場合、
`/usr/local/shellbox/containers/<コマンド名>/mounts.conf` を編集してください。

- `-v` オプション形式`ローカルDir:コンテナDir`で記述（1行につき1マウント）
- コメント行（`#`）と空行は無視されます
- 例:

```text
/home/takashi/.ssh:/root/.ssh:ro
/tmp/output:/out
```

---

## 🧰 カスタムテンプレートの考え方

ShellBoxは、`/usr/local/shellbox/bin/runsh_template.sh` をテンプレートとして使用し、各コマンドに応じたコンテナの実行スクリプト（**ShellBoxスクリプト**）を生成します。

原則として、ShellBoxスクリプトは引数 `$@` を一切加工せず、そのままコンテナの `podman run` に透過的に渡します。これにより、幅広いコマンドに対応できる汎用的な仕組みを実現しています。

ただし、以下のような「特殊な引数構造」や「入出力の制約」があるコマンドについては、必要に応じてテンプレートスクリプト（`runsh_template.sh`）あるいは、`shellbox install` によって`/usr/local/shellbox/bin`に作成されるShellBoxスクリプトをカスタマイズして対応してください。

---

### 🔸 カスタマイズが有効なケース

| コマンド例 | 特殊な事情 |
|------------|----------------|
| `jq` | 標準入力が必要。`echo ... \| jq` のような形をとるため、Podmanに `-i` オプションを付与して stdin を有効にする必要がある。 |
| `openssl req -new` | 対話的入力が発生するため、`-it` を付けて pseudo-TTY を有効にする必要がある。 |
| `convert input.png output.jpg` | 明示的にファイルを参照するため、ホスト側ファイルが `/mnt/` にあることを前提としてShellBoxスクリプトを調整する必要がある。 |

---

### 💡 標準入力（stdin）についての注意

ShellBoxスクリプトのデフォルトでは、Podmanに `-i`（標準入力を有効にする）オプションを**付けていません**。  
そのため、以下のような「標準入力を使うコマンド」は、そのままでは正しく動作しない可能性があります。

#### 例：

```sh
# ❌ デフォルトのShellBoxスクリプトでは反応しない例
echo '{"foo": 1}' | my_jq '.foo'
```

このような場合は、ShellBoxスクリプトを以下のようにカスタマイズしてください：

```sh
#!/bin/sh
CMD_IMAGE="{{CMD_IMAGE}}"

if ! podman run --rm -i -v "$PWD":/mnt "$CMD_IMAGE" "$@"; then
    echo "❌ 実行エラー: stdinを使う処理で失敗しました。" >&2
    exit 1
fi
```

TTYが必要な場合（対話的コマンド）には、`-it` に変更してください。

#### 🔧 カスタマイズ例（TTY付き）

```sh
#!/bin/sh
CMD_IMAGE="{{CMD_IMAGE}}"

if ! podman run --rm -it -v "$PWD":/mnt "$CMD_IMAGE" "$@"; then
    echo "❌ 実行エラー: TTYが必要な処理で失敗しました。" >&2
    exit 1
fi
```

---

### 📌 運用ルールの提案

- 一般的なコマンド（`ls`, `python`, `grep` など）は、そのままのShellBoxスクリプトで `$@` を透過させるだけで動作します。
- 特殊な入出力要件がある場合は、各ShellBoxスクリプトやコンテナイメージ（DockerfileやENTRYPOINT）で柔軟に対応してください。
- **ShellBox本体は引数や入出力の意味を解釈しません。コマンドごとの責任分離と再利用性を重視しています。**

---

## 最後に

ShellBoxは、「ホスト環境を守る」というただ一点に特化した実行環境カプセルです。
開発者の精神衛生を守るために、ぜひご活用ください。

あと、なんか「こんな楽しい使い方あるよ！」とか「こんな使い方考えた！」とかあれば、ぜひプルリクください。
