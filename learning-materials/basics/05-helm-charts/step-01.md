# Step 1: Helm Charts and Templating

---

## Understanding Helm Charts

A Helm chart is a collection of files that describe a related set of Kubernetes resources.

### Chart Structure

```
my-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── values.schema.json      # Values schema (optional)
├── templates/              # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── _helpers.tpl        # Reusable template helpers
│   └── NOTES.txt           # Post-install notes
└── charts/                 # Dependency charts
```

### Chart.yaml

```yaml
apiVersion: v2
name: myapp
description: A Helm chart for Kubernetes
type: application
version: 0.1.0     # Chart version (semver)
appVersion: "1.0.0" # Application version
```

| Field | Purpose |
|-------|---------|
| **apiVersion** | Helm chart API version (v2 for Helm 3) |
| **name** | Chart name (must match directory name) |
| **description** | Short description of the chart |
| **version** | Chart version (follows semver) |
| **appVersion** | Version of the application being deployed |

## values.yaml Structure

The values.yaml file contains default configuration values:

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""  # Defaults to Chart.AppVersion if empty

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

## Template Syntax

Helm uses Go template syntax with Sprig functions:

| Syntax | Description | Example |
|--------|-------------|---------|
| `{{ .Values.key }}` | Insert value | `{{ .Values.replicaCount }}` |
| `{{ include "name" . }}` | Call named template | `{{ include "myapp.fullname" . }}` |
| `{{- }}` | Trim left whitespace | `{{- include "myapp.labels" . }}` |
| `-}}` | Trim right whitespace | `{{ .Values.key }}` |
| `{{- if }}...{{- end }}` | Conditional | `{{- if .Values.ingress.enabled }}` |
| `{{- range }}...{{- end }}` | Loop | `{{- range .Values.items }}` |
| `\| nindent N` | Indent output | `{{ include "labels" . \| nindent 4 }}` |
| `\| default }}` | Default value | `{{ .Values.tag \| default "latest" }}` |
| `\| quote }}` | Quote string | `{{ .Values.name \| quote }}` |

## Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
        readinessProbe:
          httpGet:
            path: /
            port: http
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

## Helper Functions

The `_helpers.tpl` file contains reusable template partials:

```yaml
{{- /*
Expand the name of the chart.
*/}}
{{- define "myapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Create a default fully qualified app name.
*/}}
{{- define "myapp.fullname" -}}
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

{{- /*
Create chart name and version as used by the chart label.
*/}}
{{- define "myapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Common labels
*/}}
{{- define "myapp.labels" -}}
helm.sh/chart: {{ include "myapp.chart" . }}
{{ include "myapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- /*
Selector labels
*/}}
{{- define "myapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

## Your Task: Create a Chart

1. Create a new chart:
```bash
helm create myapp
cd myapp
```

2. Examine Chart.yaml and update it:
```yaml
apiVersion: v2
name: myapp
description: My custom application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

3. Review templates/deployment.yaml and identify:
- Where values from values.yaml are used
- How helper functions are called
- How the container image is constructed

4. Modify values.yaml:
```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25-alpine"
```

5. Test template rendering:
```bash
helm template myapp .
```

---

## Quick Check

Test your understanding:

1. What's the difference between Chart version and appVersion? (Chart version is the version of the Helm chart itself using semver; appVersion is the version of the application being deployed)

2. What does the `include` function do in Helm templates? (Calls a named template partial and inserts its output at that location)

3. What's the purpose of values.yaml? (Contains default configuration values that can be overridden during install/upgrade to customize the deployment)

4. What does the `nindent` function do? (Indents the output by N spaces, useful for maintaining YAML structure in templates)

5. What's a Helm release? (A single instance of a chart deployed to a Kubernetes cluster, with a unique name and tracked revision history)

---

**Continue to `step-02.md`**
