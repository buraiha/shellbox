#!/bin/bash

set -euo pipefail

SHELLBOX_HOME="/usr/local/shellbox"
BIN_DIR="$SHELLBOX_HOME/bin"
LIB_DIR="$SHELLBOX_HOME/lib"
SCRIPT_PATH="$BIN_DIR/shellbox"
SCRIPT_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/bin/shellbox"
UNINSTALL_PATH="$LIB_DIR/uninstall.sh"
UNINSTALL_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/uninstall.sh"
VERSION_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/VERSION"
VERSION="$(curl -sSL "$VERSION_URL")"

# --force 対応
if [[ "${1:-}" == "--force" ]]; then
    echo "🧨 --force 指定あり。ShellBox を強制削除してから再インストールします。"
    sudo rm -rf "$SHELLBOX_HOME"
fi

# すでにインストールされていれば中止
if [ -f "$SCRIPT_PATH" ]; then
    echo "✅ すでに ShellBox はインストールされています: $SCRIPT_PATH"
    echo "   再インストールしたい場合は、--force を付けて再実行してください。"
    exit 0
fi

echo "🛠 ShellBox $VERSION のセットアップを開始します...(必要に応じて、suのパスワードを聞かれる場合があります)"

# ディレクトリ作成と権限
sudo mkdir -p "$BIN_DIR" "$LIB_DIR"
sudo chown -R "$(whoami)" "$SHELLBOX_HOME"

# shellbox スクリプトの設置
curl -sSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"
sudo chown "$(whoami)" "$SCRIPT_PATH"

# uninstall.sh の設置
curl -sSL "$UNINSTALL_URL" -o "$UNINSTALL_PATH"
chmod +x "$UNINSTALL_PATH"
sudo chown "$(whoami)" "$UNINSTALL_PATH"

# 利用中のシェルに応じて .bashrc or .zshrc に PATH を追記
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "$BIN_DIR" "$SHELL_RC"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "✅ PATH に $BIN_DIR を $SHELL_RC に追加しました（次回ログイン以降有効）"
fi

# 初期化コマンド実行
"$SCRIPT_PATH" init

echo "🎉 ShellBox のインストールが完了しました！"
echo "📦 アンインストールしたい場合は: $SCRIPT_PATH uninstall"
