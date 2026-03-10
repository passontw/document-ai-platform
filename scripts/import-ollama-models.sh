#!/usr/bin/env bash
set -euo pipefail

IMPORT_DIR="${1:-./ollama-exports}"
CONTAINER_NAME="${OLLAMA_CONTAINER:-ollama}"

if [ ! -d "$IMPORT_DIR" ]; then
  echo "錯誤：找不到目錄 '$IMPORT_DIR'"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "錯誤：找不到執行中的容器 '$CONTAINER_NAME'"
  exit 1
fi

BACKUP_FILE="$IMPORT_DIR/ollama_data.tar.gz"

if [ -f "$BACKUP_FILE" ]; then
  echo "還原 Ollama volume 資料..."
  docker run --rm \
    -v ollama_data:/data \
    -v "$(realpath "$IMPORT_DIR")":/backup \
    alpine sh -c "cd /data && tar xzf /backup/ollama_data.tar.gz"
  echo "完成：Ollama 資料已還原"
else
  echo "找不到備份檔案 '$BACKUP_FILE'，跳過還原"
fi

echo "重啟 Ollama 容器以載入模型..."
docker restart "$CONTAINER_NAME"

echo "完成：Ollama 模型已匯入"
