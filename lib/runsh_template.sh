#!/bin/bash
set -euo pipefail

CMD_IMAGE="shellbox_{{CMD_NAME}}"

# 追加マウント定義ファイル (存在すれば使用)
EXTRA_MOUNTS_FILE="/usr/local/shellbox/containers/{{CMD_NAME}}/mounts.conf"
EXTRA_MOUNTS=()

# ROOTモードコマンドの判定
ROOT_FLAG_PATH="/usr/local/shellbox/containers/{{CMD_NAME}}/as-root.flag"
USE_SUDO=""
if [[ -f "$ROOT_FLAG_PATH" ]]; then
    USE_SUDO="sudo"
fi

if [[ -f "$EXTRA_MOUNTS_FILE" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        EXTRA_MOUNTS+=("-v" "$line")
    done < "$EXTRA_MOUNTS_FILE"
fi

$USE_SUDO podman run --rm \
    -v "$PWD":/mnt \
    -w /mnt \
    ${EXTRA_MOUNTS+"${EXTRA_MOUNTS[@]}"} \
    "$CMD_IMAGE" "$@"
