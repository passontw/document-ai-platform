#!/usr/bin/env bash
set -euo pipefail

EXPORT_DIR="${1:-./ollama-exports}"
mkdir -p "$EXPORT_DIR"

CONTAINER_NAME="${OLLAMA_CONTAINER:-ollama}"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "錯誤：找不到執行中的容器 '$CONTAINER_NAME'"
  exit 1
fi

MODELS=$(docker exec "$CONTAINER_NAME" ollama list | tail -n +2 | awk '{print $1}')

if [ -z "$MODELS" ]; then
  echo "找不到任何 Ollama 模型"
  exit 0
fi

echo "$MODELS" | while read -r model; do
  filename="${model//:/\_}.tar"
  echo "匯出模型 $model -> $EXPORT_DIR/$filename"
  docker exec "$CONTAINER_NAME" ollama show "$model" --modelfile > "$EXPORT_DIR/${model//:/\_}.modelfile"
done

echo "備份 Ollama volume 資料..."
docker run --rm \
  -v ollama_data:/data \
  -v "$(realpath "$EXPORT_DIR")":/backup \
  alpine tar czf /backup/ollama_data.tar.gz -C /data .

echo "完成：Ollama 模型已匯出至 $EXPORT_DIR"
