# Document AI Platform

本地 AI 文件處理平台，包含 n8n + Ollama 工作流程引擎與 Penpot 設計工具。

## 服務

| 服務 | 埠 | 說明 |
|------|----|------|
| n8n | 5678 | 工作流程自動化 |
| Ollama | 11434 | 本地 LLM |
| Penpot | 9001 | 設計工具 |

## 啟動

```bash
cp .env.example .env
# 編輯 .env 填入正確的 MAC_MINI_IP 與密碼

docker compose -f docker-compose.ai.yml up -d
docker compose -f docker-compose.penpot.yml up -d
```

## 備份與還原

```bash
# 匯出 Docker images
./scripts/export-images.sh

# 匯出 Ollama 模型
./scripts/export-ollama-models.sh

# 匯入 Docker images
./scripts/import-images.sh

# 匯入 Ollama 模型
./scripts/import-ollama-models.sh
```
