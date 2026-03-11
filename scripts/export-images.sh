#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
EXPORT_DIR="${1:-$REPO_DIR/image-exports}"
mkdir -p "$EXPORT_DIR"

IMAGES=()
while IFS= read -r line; do
  IMAGES+=("$line")
done < <(
  docker compose \
    -f "$REPO_DIR/docker-compose.basic.yml" \
    -f "$REPO_DIR/docker-compose.ai.yml" \
    -f "$REPO_DIR/docker-compose.penpot.yml" \
    config --images 2>/dev/null
)

APPFLOWY_IMAGES=(
  "appflowyinc/appflowy_cloud:latest"
  "appflowyinc/gotrue:latest"
  "nginx:alpine"
)

exported=0
skipped=0

for image in "${IMAGES[@]}"; do
  if ! docker image inspect "$image" &>/dev/null; then
    echo "略過（本地不存在）：$image"
    skipped=$((skipped + 1))
    continue
  fi
  filename="${image//\//_}"
  filename="${filename//:/_}.tar"
  echo "匯出 $image -> $EXPORT_DIR/$filename"
  docker save "$image" -o "$EXPORT_DIR/$filename"
  exported=$((exported + 1))
done

echo "打包 AppFlowy images -> $EXPORT_DIR/images-appflowy.tar.gz"
appflowy_available=()
for image in "${APPFLOWY_IMAGES[@]}"; do
  if docker image inspect "$image" &>/dev/null; then
    appflowy_available+=("$image")
  else
    echo "略過（本地不存在）：$image"
    skipped=$((skipped + 1))
  fi
done

if [ ${#appflowy_available[@]} -gt 0 ]; then
  docker save "${appflowy_available[@]}" | gzip > "$EXPORT_DIR/images-appflowy.tar.gz"
  exported=$((exported + ${#appflowy_available[@]}))
fi

echo "產生 checksums..."
(cd "$EXPORT_DIR" && find . -name "*.tar" -o -name "*.tar.gz" | sort | xargs sha256sum > checksums.sha256)

echo "完成：匯出 $exported 個，略過 $skipped 個（未拉取）"
