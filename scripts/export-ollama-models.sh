#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
EXPORT_DIR="${1:-$REPO_DIR/ollama-exports}"
mkdir -p "$EXPORT_DIR"

CONTAINER_NAME="${OLLAMA_CONTAINER:-ollama}"

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  MODELS=$(docker exec "$CONTAINER_NAME" ollama list | tail -n +2 | awk '{print $1}')
  if [ -z "$MODELS" ]; then
    echo "容器中沒有已下載的模型，略過 modelfile 匯出"
  else
    echo "$MODELS" | while read -r model; do
      echo "匯出 modelfile：$model"
      docker exec "$CONTAINER_NAME" ollama show "$model" --modelfile > "$EXPORT_DIR/${model//:/\_}.modelfile"
    done
  fi
else
  echo "警告：容器 '$CONTAINER_NAME' 未執行，略過 modelfile 匯出"
fi

echo "備份 ollama_data volume..."
docker run --rm \
  -v ollama_data:/data \
  -v "$(realpath "$EXPORT_DIR")":/backup \
  alpine tar czf /backup/ollama_data.tar.gz -C /data .

echo "完成：Ollama 資料已匯出至 $EXPORT_DIR"
