#!/bin/bash
set -euo pipefail

SHELLBOX_HOME="/usr/local/shellbox"
BIN_DIR="$SHELLBOX_HOME/bin"
LIB_DIR="$SHELLBOX_HOME/lib"
SCRIPT_PATH="$BIN_DIR/shellbox"

SCRIPT_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/bin/shellbox"
UNINSTALL_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/lib/uninstall.sh"
TEMPLATE_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/lib/runsh_template.sh"
MOUNTS_TEMPLATE_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/lib/mounts_template.conf"
DOCKERFILE_TEMPLATE_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/lib/dockerfile_template.Dockerfile"
VERSION_URL="https://raw.githubusercontent.com/buraiha/shellbox/main/VERSION"
VERSION="$(curl -sSL "$VERSION_URL")"

# wslにはインストールできません
# 詳細はREADME.mdを参照ください。https://github.com/buraiha/shellbox
if grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then
  echo "❌ この環境はWSLと判定されました。ShellBoxはWSLでは使用できません。"
  echo "🛑 ShellBoxはすでに仮想環境上であるWSLにインストールする必要はありません。"
  echo "    詳細はREADME.mdを参照してください: https://github.com/buraiha/shellbox"
  exit 1
fi

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

echo "🛠 ShellBox $VERSION のセットアップを開始します..."

# ディレクトリ作成
sudo mkdir -p "$BIN_DIR" "$LIB_DIR"
sudo chown -R "$(whoami)" "$SHELLBOX_HOME"

# スクリプト設置
curl -sSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

curl -sSL "$UNINSTALL_URL" -o "$LIB_DIR/uninstall.sh"
chmod +x "$LIB_DIR/uninstall.sh"

curl -sSL "$TEMPLATE_URL" -o "$LIB_DIR/runsh_template.sh"
chmod +x "$LIB_DIR/runsh_template.sh"

curl -sSL "$MOUNTS_TEMPLATE_URL" -o "$LIB_DIR/mounts_template.conf"
chmod 644 "$LIB_DIR/mounts_template.conf"

curl -sSL "$DOCKERFILE_TEMPLATE_URL" -o "$LIB_DIR/dockerfile_template.Dockerfile"
chmod 644 "$LIB_DIR/dockerfile_template.Dockerfile"

# PATH 設定（zsh or bash）
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "$BIN_DIR" "$SHELL_RC"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "✅ $SHELL_RC に PATH の設定を追加しました。"
    echo "   すぐに反映させるには: source \"$SHELL_RC\""
    echo "   または、シェルを再起動／再ログインしてください。"
fi

# ShellBox 初期化
"$SCRIPT_PATH" init

# バージョンファイル保存
curl -sSL "$VERSION_URL" -o "$SHELLBOX_HOME/VERSION"

echo "🎉 ShellBox のインストールが完了しました！"
echo "📦 アンインストールしたい場合は: $SCRIPT_PATH uninstall"
