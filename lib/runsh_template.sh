#!/bin/bash
set -euo pipefail

CMD_IMAGE="shellbox_{{CMD_NAME}}"

# 追加マウント定義ファイル (存在すれば使用)
EXTRA_MOUNTS_FILE="/usr/local/shellbox/containers/{{CMD_NAME}}/mounts.conf"
EXTRA_MOUNTS=()

if [[ -f "$EXTRA_MOUNTS_FILE" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        EXTRA_MOUNTS+=("-v" "$line")
    done < "$EXTRA_MOUNTS_FILE"
fi

podman run --rm \
    -v "$PWD":/mnt \
    ${EXTRA_MOUNTS+"${EXTRA_MOUNTS[@]}"} \
    "$CMD_IMAGE" "$@"
