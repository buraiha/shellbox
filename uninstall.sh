#!/bin/bash
set -euo pipefail

SHELLBOX_HOME="/usr/local/shellbox"
BIN_DIR="$SHELLBOX_HOME/bin"

echo "⚠ ShellBox をアンインストールします..."

read -p "本当に削除してよろしいですか？ [$SHELLBOX_HOME] (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    echo "🗑 ShellBox ディレクトリを削除中..."
    sudo rm -rf "$SHELLBOX_HOME"
    echo "✅ 削除完了: $SHELLBOX_HOME"

    # シェル判定
    case "$SHELL" in
        */zsh) SHELL_RC="$HOME/.zshrc" ;;
        *)     SHELL_RC="$HOME/.bashrc" ;;
    esac

    # PATH 削除（BSD sed/macOS対応: 区切り記号に # を使用）
    if [ -f "$SHELL_RC" ] && grep -q "$BIN_DIR" "$SHELL_RC"; then
        sed -i.bak "\#${BIN_DIR}#d" "$SHELL_RC"
        echo "✅ $SHELL_RC から PATH を削除しました（バックアップ: $SHELL_RC.bak）"
        echo "🔁 反映するには: source $SHELL_RC"
    else
        echo "ℹ PATH は $SHELL_RC に見つかりませんでした。"
    fi
else
    echo "🚫 アンインストールをキャンセルしました。"
fi
