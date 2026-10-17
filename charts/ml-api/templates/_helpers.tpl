
{{- define "ml-api.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ml-api.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ml-api.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "ml-api.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.model.name }}
ml-platform/model-name: {{ . | quote }}
{{- end }}
{{- if .Values.model.version }}
ml-platform/model-version: {{ .Values.model.version | toString | quote }}
{{- end }}
{{- if .Values.datadog.enabled }}
tags.datadoghq.com/env: {{ .Values.datadog.env | default .Release.Namespace | quote }}
tags.datadoghq.com/service: {{ include "ml-api.fullname" . | quote }}
tags.datadoghq.com/version: {{ .Values.model.version | default (.Values.image.tag | default .Chart.AppVersion) | toString | quote }}
{{- end }}
{{- end }}

{{- define "ml-api.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else if .Values.secrets.external.enabled -}}
{{- printf "%s-secrets" (include "ml-api.fullname" .) -}}
{{- end -}}
{{- end }}
