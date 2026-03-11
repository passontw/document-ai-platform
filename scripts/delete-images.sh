#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

IMAGES=()
while IFS= read -r line; do
  IMAGES+=("$line")
done < <(
  docker compose \
    -f "$REPO_DIR/docker-compose.basic.yml" \
    -f "$REPO_DIR/docker-compose.ai.yml" \
    -f "$REPO_DIR/docker-compose.penpot.yml" \
    -f "$REPO_DIR/docker-compose.appflowy.yml" \
    config --images 2>/dev/null
)

echo "以下 image 將被刪除："
for image in "${IMAGES[@]}"; do
  echo "  - $image"
done

read -r -p "確認刪除？[y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "已取消"
  exit 0
fi

removed=0
skipped=0

for image in "${IMAGES[@]}"; do
  if ! docker image inspect "$image" &>/dev/null; then
    echo "略過（本地不存在）：$image"
    skipped=$((skipped + 1))
    continue
  fi
  echo "刪除 $image..."
  docker rmi "$image"
  removed=$((removed + 1))
done

echo "完成：刪除 $removed 個，略過 $skipped 個"
