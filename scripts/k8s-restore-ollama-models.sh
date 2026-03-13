#!/usr/bin/env bash
set -euo pipefail

# 將 Ollama 模型資料還原到 K8s PVC
# 前提：已執行 helm install 建立 PVC
# 用法：./k8s-restore-ollama-models.sh [備份目錄] [namespace] [pvc名稱]

IMPORT_DIR="${1:-./ollama-exports}"
NAMESPACE="${2:-ai-services}"
PVC_NAME="${3:-ai-services-ollama}"

BACKUP_FILE="$IMPORT_DIR/ollama_data.tar.gz"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "錯誤：找不到備份檔案 '$BACKUP_FILE'"
  exit 1
fi

BACKUP_ABSOLUTE="$(cd "$(dirname "$BACKUP_FILE")" && pwd)/$(basename "$BACKUP_FILE")"

echo "準備還原 Ollama 模型資料..."
echo "  備份檔案：$BACKUP_ABSOLUTE"
echo "  Namespace：$NAMESPACE"
echo "  PVC：$PVC_NAME"

# 先將備份檔案複製到節點上的臨時目錄
TEMP_DIR="/tmp/ollama-restore-$$"
echo "建立臨時目錄 $TEMP_DIR..."
sudo mkdir -p "$TEMP_DIR"
sudo cp "$BACKUP_ABSOLUTE" "$TEMP_DIR/"

# 使用臨時 Pod 掛載 PVC 並還原資料
echo "建立還原 Pod..."
kubectl run ollama-restore \
  --rm -i \
  --restart=Never \
  --namespace "$NAMESPACE" \
  --image=busybox:1.36 \
  --overrides="{
    \"spec\": {
      \"containers\": [{
        \"name\": \"restore\",
        \"image\": \"busybox:1.36\",
        \"command\": [\"sh\", \"-c\", \"cd /data && tar xzf /backup/ollama_data.tar.gz && echo done\"],
        \"stdin\": true,
        \"volumeMounts\": [
          {\"name\": \"ollama-data\", \"mountPath\": \"/data\"},
          {\"name\": \"backup\", \"mountPath\": \"/backup\"}
        ]
      }],
      \"volumes\": [
        {\"name\": \"ollama-data\", \"persistentVolumeClaim\": {\"claimName\": \"$PVC_NAME\"}},
        {\"name\": \"backup\", \"hostPath\": {\"path\": \"$TEMP_DIR\"}}
      ]
    }
  }"

# 清理臨時目錄
echo "清理臨時檔案..."
sudo rm -rf "$TEMP_DIR"

# 重啟 Ollama Pod 以載入模型
echo "重啟 Ollama Pod..."
kubectl rollout restart deployment -n "$NAMESPACE" -l app.kubernetes.io/component=ollama

echo "完成：Ollama 模型已還原"
