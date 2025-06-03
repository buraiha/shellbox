#!/bin/bash

set -e

SHELLBOX_HOME="/usr/local/shellbox"
BIN_DIR="$SHELLBOX_HOME/bin"
SCRIPT_PATH="$BIN_DIR/shellbox"
SCRIPT_URL="https://raw.githubusercontent.com/youruser/yourrepo/main/bin/shellbox"

echo "🛠 ShellBox セットアップを開始します..."

# すでにインストールされているか確認
if [ -f "$SCRIPT_PATH" ]; then
    echo "✅ すでに ShellBox はインストールされています: $SCRIPT_PATH"
    echo "   再インストールしたい場合は、手動で削除するか、上書きフラグをつけてください。"
    echo "   例: rm -f $SCRIPT_PATH && 再度このスクリプトを実行"
    exit 0
fi

# SHELLBOX_HOME 作成
sudo mkdir -p "$BIN_DIR"
sudo chown -R "$(whoami)" "$SHELLBOX_HOME"

# スクリプト取得・設置
curl -sSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# PATH に追加
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> ~/.bashrc
    echo "✅ PATH に $BIN_DIR を追加しました（次回ログイン以降有効）"
fi

# 初期化
"$SCRIPT_PATH" init

echo "🎉 ShellBox のインストールが完了しました！"
