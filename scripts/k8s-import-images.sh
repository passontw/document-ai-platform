#!/usr/bin/env bash
set -euo pipefail

# 將 Docker 格式的 .tar 映像檔匯入到 k3s containerd
# 用法：./k8s-import-images.sh [映像檔目錄]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMPORT_DIR="${1:-$REPO_DIR/image-exports}"

if [ ! -d "$IMPORT_DIR" ]; then
  echo "錯誤：找不到目錄 '$IMPORT_DIR'"
  exit 1
fi

# 驗證 checksum
if [ -f "$IMPORT_DIR/checksums.sha256" ]; then
  echo "驗證 checksums..."
  (cd "$IMPORT_DIR" && sha256sum -c checksums.sha256) || {
    echo "錯誤：checksum 驗證失敗，請確認檔案完整性"
    exit 1
  }
fi

imported=0
shopt -s nullglob

for tar_file in "$IMPORT_DIR"/*.tar "$IMPORT_DIR"/*.tar.gz; do
  echo "匯入 $tar_file 到 k3s containerd..."
  sudo k3s ctr images import "$tar_file"
  imported=$((imported + 1))
done

echo "完成：匯入 $imported 個映像檔"
echo ""
echo "已載入的映像檔清單："
sudo k3s ctr images list | grep -E "ollama|n8n|busybox" || true
