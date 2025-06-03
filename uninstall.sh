#!/bin/bash

SHELLBOX_HOME="/usr/local/shellbox"
BIN_DIR="$SHELLBOX_HOME/bin"

echo "⚠ ShellBox をアンインストールします..."

read -p "本当に削除してよろしいですか？ [$SHELLBOX_HOME] (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo rm -rf "$SHELLBOX_HOME"
    echo "✅ ShellBox ディレクトリを削除しました。"

    if grep -q "$BIN_DIR" ~/.bashrc; then
        sed -i.bak "/$BIN_DIR/d" ~/.bashrc
        echo "✅ ~/.bashrc から PATH 追記を削除しました（.bak にバックアップあり）"
    fi

    echo "🔁 反映するには `source ~/.bashrc` を実行してください。"
else
    echo "キャンセルしました。"
fi
