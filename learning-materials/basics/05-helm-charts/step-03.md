# Step 3: Environment Configurations and Advanced Features

---

## Environment-Specific Values

Best practice: Use different values files for each environment.

### Values Files Strategy

```
myapp/
├── values.yaml           # Defaults
├── values-dev.yaml       # Development overrides
├── values-staging.yaml   # Staging overrides
└── values-prod.yaml      # Production overrides
```

### Example Values Files

**values-dev.yaml:**
```yaml
replicaCount: 1

image:
  tag: "dev"

config:
  logLevel: debug
  featureFlags:
    newFeature: true

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
```

**values-prod.yaml:**
```yaml
replicaCount: 3

image:
  tag: "1.0.0"

config:
  logLevel: warn
  featureFlags:
    newFeature: false

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls

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

### Installing with Values Files

```bash
# Development
helm install myapp-dev ./myapp -f values-dev.yaml -n dev

# Staging
helm install myapp-staging ./myapp -f values-staging.yaml -n staging

# Production
helm install myapp-prod ./myapp -f values-prod.yaml -n production
```

## Conditional Resources

Use `if` to conditionally create resources:

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- toYaml .Values.ingress.tls | nindent 4 }}
  {{- end }}
  rules:
    {{- toYaml .Values.ingress.rules | nindent 4 }}
{{- end }}
```

## Loops

Create multiple resources from a list:

```yaml
{{- range .Values.environments }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" $ }}-{{ . }}
data:
  environment: {{ . }}
{{- end }}
```

With values:
```yaml
environments:
  - dev
  - staging
  - prod
```

Result: Creates 3 ConfigMaps (myapp-dev, myapp-staging, myapp-prod)

## Dependencies

Add chart dependencies in Chart.yaml:

```yaml
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  - name: redis
    version: 17.x.x
    repository: https://charts.bitnami.com/bitnami
```

Update dependencies:
```bash
helm dependency update
```

Use in values:
```yaml
postgresql:
  enabled: true
  auth:
    password: secretpassword

redis:
  enabled: false
```

## Hooks

Run actions at specific points in the release lifecycle:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-migrate"
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  annotations:
    # This defines the hook
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    metadata:
      name: "{{ .Release.Name }}-migrate"
    spec:
      restartPolicy: Never
      containers:
      - name: migrate
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        command: ["python", "manage.py", "migrate"]
```

| Hook | Runs When |
|------|-----------|
| **pre-install** | Before the first installation |
| **post-install** | After the first installation |
| **pre-upgrade** | Before an upgrade |
| **post-upgrade** | After an upgrade |
| **pre-delete** | Before deletion |
| **post-delete** | After deletion |
| **pre-rollback** | Before rollback |
| **post-rollback** | After rollback |

## NOTES.txt

Provide post-install instructions to users:

```yaml
{{- /*
Generated NOTES.txt provides helpful post-install information
*/}}
{{- if .Values.ingress.enabled }}
Thank you for installing {{ .Chart.Name }}!

Your release is named {{ .Release.Name }}.

To learn more about the release, try:

  $ helm status {{ .Release.Name }}
  $ helm get all {{ .Release.Name }}

The application is accessible via:

{{- range .Values.ingress.hosts }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ .host }}
{{- end }}
{{- else }}
Thank you for installing {{ .Chart.Name }}!

Your release is named {{ .Release.Name }}.

The application is not accessible from outside the cluster.
Use port-forwarding to access it:

  kubectl port-forward svc/{{ include "myapp.fullname" . }} 8080:80
{{- end }}
```

---

## Quick Check

Test your understanding:

1. Why use separate values files for different environments? (To maintain environment-specific configurations like replica counts, resource limits, and feature flags in separate files while using the same chart)

2. How do you conditionally create a resource based on a values setting? (Use `{{- if .Values.resource.enabled }}` before the resource definition and `{{- end }}` after it)

3. What are Helm hooks used for? (To execute actions at specific points in the release lifecycle, like running database migrations after installation)

4. What's the purpose of NOTES.txt? (To display helpful post-install information to users after running helm install, such as access URLs and next steps)

5. How do chart dependencies work? (Define them in Chart.yaml with name, version, and repository; run `helm dependency update` to download them into the charts/ directory)

---

**Continue to `solution.md`**
