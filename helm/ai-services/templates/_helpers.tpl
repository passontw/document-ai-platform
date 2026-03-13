{{/*
Chart 名稱
*/}}
{{- define "ai-services.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
完整名稱（含 release name）
*/}}
{{- define "ai-services.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Namespace
*/}}
{{- define "ai-services.namespace" -}}
{{- default .Release.Namespace .Values.global.namespace }}
{{- end }}

{{/*
共用 labels
*/}}
{{- define "ai-services.labels" -}}
helm.sh/chart: {{ include "ai-services.name" . }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: document-ai-platform
{{- end }}

{{/*
Ollama 資源名稱
*/}}
{{- define "ai-services.ollama.fullname" -}}
{{- printf "%s-ollama" (include "ai-services.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Ollama selector labels
*/}}
{{- define "ai-services.ollama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-services.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: ollama
{{- end }}

{{/*
Ollama 內部 URL（供 n8n 使用）
*/}}
{{- define "ai-services.ollama.url" -}}
{{- printf "http://%s:%v" (include "ai-services.ollama.fullname" .) .Values.ollama.service.port }}
{{- end }}

{{/*
n8n 資源名稱
*/}}
{{- define "ai-services.n8n.fullname" -}}
{{- printf "%s-n8n" (include "ai-services.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
n8n selector labels
*/}}
{{- define "ai-services.n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-services.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: n8n
{{- end }}

{{/*
n8n Secret 名稱
*/}}
{{- define "ai-services.n8n.secretName" -}}
{{- if .Values.n8n.auth.existingSecret }}
{{- .Values.n8n.auth.existingSecret }}
{{- else }}
{{- include "ai-services.n8n.fullname" . }}
{{- end }}
{{- end }}
