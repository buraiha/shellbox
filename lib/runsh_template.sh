#!/bin/sh
CMD_IMAGE="{{CMD_IMAGE}}"

if ! podman run --rm -v "$PWD":/mnt "$CMD_IMAGE" "$@"; then
    echo "❌ ShellBox 実行エラー: ディレクトリのマウントに失敗した可能性があります。" >&2
    echo "💡 macOS環境では \$HOME 配下で実行してください。" >&2
    exit 1
fi
