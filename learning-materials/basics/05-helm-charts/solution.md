# Solution: Helm Charts

## Complete Chart Files

### Chart.yaml
```yaml
apiVersion: v2
name: myapp
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### values.yaml
```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources: {}
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

### templates/deployment.yaml
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

### templates/_helpers.tpl
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

### Environment Values Files

**values-dev.yaml:**
```yaml
replicaCount: 1

image:
  tag: "dev"

config:
  logLevel: debug

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

**values-prod.yaml:**
```yaml
replicaCount: 3

image:
  tag: "1.0.0"

config:
  logLevel: warn

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

## Common Commands

```bash
# Create a chart
helm create myapp

# Install with default values
helm install myapp ./myapp

# Dry run to test
helm install myapp ./myapp --dry-run --debug

# Install with custom values
helm install myapp ./myapp -f values-prod.yaml

# Install with inline overrides
helm install myapp ./myapp --set replicaCount=5

# List releases
helm list
helm list --all-namespaces

# Get release info
helm status myapp
helm get manifest myapp
helm get values myapp

# View history
helm history myapp

# Upgrade
helm upgrade myapp ./myapp
helm upgrade myapp ./myapp -f values-prod.yaml

# Rollback
helm rollback myapp
helm rollback myapp 1

# Uninstall
helm uninstall myapp
```

## Key Concepts Demonstrated

| Concept | Description |
|---------|-------------|
| **Chart** | Package containing templates, values, and metadata |
| **Release** | Instance of a chart deployed to the cluster |
| **Values** | Configuration that customizes the chart |
| **Templates** | Go templates that generate Kubernetes manifests |
| **Helpers** | Reusable template partials for common labels/names |
| **Hooks** | Actions triggered at specific points in release lifecycle |

## Best Practices

1. **Use semantic versioning** for chart versions (MAJOR.MINOR.PATCH)
2. **Keep values.yaml simple** with sensible defaults
3. **Separate environment configs** into different values files
4. **Use labels consistently** across all resources
5. **Add NOTES.txt** for helpful post-install messages
6. **Test with --dry-run** before applying changes
7. **Document custom values** in the chart README
8. **Use built-in objects** (.Release, .Values, .Chart) appropriately
9. **Implement resource limits** and requests
10. **Consider HPA** for production workloads
