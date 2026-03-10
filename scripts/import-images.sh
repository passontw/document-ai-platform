#!/usr/bin/env bash
set -euo pipefail

IMPORT_DIR="${1:-./image-exports}"

if [ ! -d "$IMPORT_DIR" ]; then
  echo "錯誤：找不到目錄 '$IMPORT_DIR'"
  exit 1
fi

shopt -s nullglob
TAR_FILES=("$IMPORT_DIR"/*.tar)

if [ ${#TAR_FILES[@]} -eq 0 ]; then
  echo "錯誤：$IMPORT_DIR 中沒有 .tar 檔案"
  exit 1
fi

for tar_file in "${TAR_FILES[@]}"; do
  echo "匯入 $tar_file..."
  docker load -i "$tar_file"
done

echo "完成：所有 images 已匯入"
