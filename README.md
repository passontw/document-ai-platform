# Document AI Platform

本地 AI 文件處理平台，包含 n8n + Ollama 工作流程引擎、Penpot 設計工具與 AppFlowy 文件協作平台。

## 服務

| 服務 | 說明 | 埠 | Network |
|------|------|----|---------|
| n8n | 工作流程自動化 | 5678 | ai |
| Ollama | 本地 LLM | 11434 | ai |
| Penpot | 設計工具 | 9001 | penpot |
| AppFlowy | 產品規格書文件平台 | 80 | appflowy |

## 存取位址

| 服務 | 位址 |
|------|------|
| n8n | http://\<MAC_MINI_IP\>:5678 |
| Ollama API | http://\<MAC_MINI_IP\>:11434 |
| Penpot | http://\<MAC_MINI_IP\>:9001 |
| AppFlowy | http://\<MAC_MINI_IP\>:80 |

## 硬體資源分配（參考）

| 服務群組 | 預估記憶體 |
|----------|-----------|
| n8n + Ollama | ~4GB（依模型大小） |
| Penpot + PostgreSQL + Valkey | ~1GB |
| AppFlowy Cloud + PostgreSQL + Redis | ~2GB |

## 快速開始

```bash
cp .env.example .env
# 編輯 .env 填入正確的 MAC_MINI_IP 與所有密碼
# APPFLOWY_JWT_SECRET 產生方式：
#   python3 -c "import secrets; print(secrets.token_urlsafe(64))"

# 1. 先啟動共用基礎設施（PostgreSQL + Valkey）
docker compose -f docker-compose.basic.yml up -d

# 2. 等待 postgres healthy 後啟動各服務
docker compose -f docker-compose.ai.yml up -d
docker compose -f docker-compose.penpot.yml up -d
docker compose -f docker-compose.appflowy.yml up -d
```

## 離線部署（Export / Import）

### 匯出

```bash
# 下載所有 images（需要網路）
./scripts/download-images.sh

# 匯出 AI + Penpot images（個別 .tar）與 AppFlowy images（images-appflowy.tar.gz）
./scripts/export-images.sh

# 匯出 Ollama 模型資料
./scripts/export-ollama-models.sh
```

產出目錄 `image-exports/` 內容：
- `*.tar` — AI 與 Penpot 各別 image
- `images-appflowy.tar.gz` — AppFlowy 相關 images 打包
- `checksums.sha256` — 所有封存檔的 checksum

### 匯入（離線目標機器）

```bash
# 匯入所有 images（驗證 checksum 後載入 .tar 與 images-appflowy.tar.gz）
./scripts/import-images.sh

# 還原 Ollama 模型資料
./scripts/import-ollama-models.sh
```
