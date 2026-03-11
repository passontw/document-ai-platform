#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMPORT_DIR="${1:-$REPO_DIR/image-exports}"

if [ ! -d "$IMPORT_DIR" ]; then
  echo "錯誤：找不到目錄 '$IMPORT_DIR'"
  exit 1
fi

if [ -f "$IMPORT_DIR/checksums.sha256" ]; then
  echo "驗證 checksums..."
  (cd "$IMPORT_DIR" && sha256sum -c checksums.sha256) || {
    echo "錯誤：checksum 驗證失敗，請確認檔案完整性"
    exit 1
  }
fi

imported=0

shopt -s nullglob

for tar_file in "$IMPORT_DIR"/*.tar; do
  echo "匯入 $tar_file..."
  docker load -i "$tar_file"
  imported=$((imported + 1))
done

if [ -f "$IMPORT_DIR/images-appflowy.tar.gz" ]; then
  echo "匯入 AppFlowy images ($IMPORT_DIR/images-appflowy.tar.gz)..."
  docker load -i "$IMPORT_DIR/images-appflowy.tar.gz"
  echo "已載入的 AppFlowy 相關 images："
  docker images | grep -E "appflowyinc|redis|nginx" || true
  imported=$((imported + 1))
fi

echo "完成：匯入 $imported 個封存檔"
