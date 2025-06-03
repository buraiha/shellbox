了解しました！
**「テスト項目 → 実行コマンド → 動作確認」** の形式で、実行可能なテスト項目にコマンド例を付記して整理し直しました👇

---

# ✅ ShellBox 初期テスト項目一覧（コマンド付き）

---

## 1. インストールテスト

### 1.1 インストールスクリプトの実行

* 🧪 **コマンド**

  ```sh
  curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/install.sh | bash
  ```

* 🔍 **動作確認**

  * `/usr/local/shellbox/bin` 等が作成される
  * `shellbox` コマンドが使えるようになる（PATHが通っていれば）

---

## 2. 初期化（init）

### 2.1 初期ディレクトリ構成の作成

* 🧪 **コマンド**

  ```sh
  shellbox init
  ```

* 🔍 **動作確認**

  * `/usr/local/shellbox/bin` 等が再作成される
  * 「✅ ディレクトリ構成を初期化しました。」と表示される

---

## 3. コマンド登録（install）

### 3.1 `ls` コマンドを distroless イメージで登録

* 🧪 **コマンド**

  ```sh
  shellbox install ls gcr.io/distroless/base-debian12:debug-nonroot
  ```

* 🔍 **動作確認**

  * `/usr/local/shellbox/bin/shellbox_ls` が作成される
  * 下記の実行でディレクトリ一覧が表示される

---

## 4. 実行スクリプトの動作

### 4.1 `shellbox_ls` の基本動作確認

* 🧪 **コマンド**

  ```sh
  shellbox_ls /mnt
  ```

* 🔍 **動作確認**

  * `$PWD` の内容が一覧表示される（マウント成功）

---

### 4.2 引数が渡るかの確認

* 🧪 **コマンド**

  ```sh
  shellbox_ls -l /mnt
  ```

* 🔍 **動作確認**

  * `-l` オプション付きの `ls` 出力が表示される

---

### 4.3 カスタムイメージ（python）の登録と実行

* 🧪 **コマンド（登録）**

  ```sh
  shellbox install py gcr.io/distroless/python3-debian12:debug-nonroot
  ```

* 🧪 **テスト用ファイル作成**

  ```python
  echo 'print("Hello, ShellBox!")' > test_script.py
  ```

* 🧪 **実行**

  ```sh
  shellbox_py /mnt/test_script.py
  ```

* 🔍 **動作確認**

  * `Hello, ShellBox!` と出力される

---

## 5. アンインストール

### 5.1 `ls` コマンドのアンインストール

* 🧪 **コマンド**

  ```sh
  shellbox uninstall ls
  ```

* 🔍 **動作確認**

  * `/usr/local/shellbox/bin/shellbox_ls` が削除される
  * `shellbox_ls` 実行時に「command not found」になる

---

## 6. Podman未インストール時の挙動

（※ このテストは Podman を意図的に無効化するか別環境で行う）

* 🧪 **Podman無効化**

  ```sh
  mv $(which podman) $(which podman)_bak
  ```

* 🧪 **任意の shellbox コマンドを実行**

  ```sh
  shellbox_ls .
  ```

* 🔍 **動作確認**

  * Podman がないことによるエラーメッセージが表示される

* 🧪 **復元**

  ```sh
  mv $(which podman)_bak $(which podman)
  ```

---

必要に応じて、CI/CDで使うスモークテストスクリプト化も可能です。
また「`shellbox list` のテスト」など、今後の機能追加に応じて拡張可能なテンプレにしてあります。ご要望あればそのまま `.md` や `.sh` にも落とし込みます。
