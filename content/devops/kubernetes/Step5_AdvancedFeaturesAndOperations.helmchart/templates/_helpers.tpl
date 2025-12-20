# kubernetes/Step5_AdvancedFeaturesAndOperations.helmchart/templates/_helpers.tpl
# Kubernetes 학습 계획 - 5단계: 고급 기능 및 운영 (Helm Chart 예시)
# 이 파일은 Helm Chart의 `_helpers.tpl` 예시입니다.
# `_helpers.tpl` 파일은 Helm 템플릿 내에서 재사용 가능한 정의, 템플릿, 함수 등을 포함합니다.
# 이를 통해 템플릿 코드의 중복을 줄이고 일관성을 유지할 수 있습니다.

{{/*
Chart의 전체 이름을 생성합니다.
Chart 이름, 릴리즈 이름, 네임스페이스를 조합하여 Kubernetes 리소스 이름의 충돌을 방지합니다.
*/}}
{{- define "my-advanced-app-chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Chart의 공통 레이블 세트를 생성합니다.
이는 모든 Kubernetes 리소스에 일관되게 적용될 수 있습니다.
*/}}
{{- define "my-advanced-app-chart.labels" -}}
helm.sh/chart: {{ include "my-advanced-app-chart.chart" . }}
{{ include "my-advanced-app-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Chart의 selector 레이블을 생성합니다.
Deployment의 `selector`와 Service의 `selector`에서 일관되게 사용됩니다.
*/}}
{{- define "my-advanced-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-advanced-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Chart 이름을 반환합니다.
*/}}
{{- define "my-advanced-app-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart 정보를 반환합니다.
*/}}
{{- define "my-advanced-app-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
서비스 어카운트 이름을 생성합니다.
*/}}
{{- define "my-advanced-app-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- default (include "my-advanced-app-chart.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
