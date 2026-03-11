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

pulled=0
failed=0

for image in "${IMAGES[@]}"; do
  echo "拉取 $image..."
  if docker pull "$image"; then
    pulled=$((pulled + 1))
  else
    echo "失敗：$image"
    failed=$((failed + 1))
  fi
done

echo "完成：成功 $pulled 個，失敗 $failed 個"
