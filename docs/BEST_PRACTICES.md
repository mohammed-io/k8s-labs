# Kubernetes & Monitoring - Best Practices

**Production-grade patterns for Kubernetes and observability.**

---

## Table of Contents

1. [Kubernetes Best Practices](#1-kubernetes-best-practices)
2. [Resource Management](#2-resource-management)
3. [Configuration Management](#3-configuration-management)
4. [Security Best Practices](#4-security-best-practices)
5. [Networking Best Practices](#5-networking-best-practices)
6. [Monitoring Best Practices](#6-monitoring-best-practices)
7. [Observability Best Practices](#7-observability-best-practices)

---

## 1. Kubernetes Best Practices

### 1.1 Always Use Deployments, Not Bare Pods

```yaml
# ❌ BAD: Bare Pod
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
  - name: web
    image: nginx:1.25

# ✅ GOOD: Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
```

**Why:** Deployments provide:
- Self-healing via ReplicaSets
- Rolling updates
- Rollback capability
- Scaling (manual and HPA)

### 1.2 Always Set Resource Requests and Limits

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    resources:
      requests:
        cpu: 100m      # Guaranteed scheduling
        memory: 128Mi  # Prevents overcommit
      limits:
        cpu: 500m      # Throttling threshold
        memory: 256Mi  # OOMKill threshold
```

**Resource QoS Classes:**

| QoS Class | Requests | Limits | Behavior |
|-----------|----------|--------|----------|
| **Guaranteed** | requests == limits | requests == limits | Highest priority, never killed for resources |
| **Burstable** | requests < limits | requests ≠ limits | Medium priority, killed if needed |
| **BestEffort** | none | none | Lowest priority, first to be killed |

### 1.3 Always Define Health Probes

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    # Startup: Allow time for app to initialize
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      failureThreshold: 30
      periodSeconds: 2
    # Liveness: Detect and restart deadlocked containers
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
      failureThreshold: 3
    # Readiness: Hold traffic until app is ready
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 2
```

### 1.4 Use Namespace Isolation

```yaml
# Create namespaces for different environments
apiVersion: v1
kind: Namespace
metadata:
  name: prod
  labels:
    environment: production
    pod-security.kubernetes.io/enforce: restricted
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    environment: staging
    pod-security.kubernetes.io/enforce: baseline
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    environment: development
```

### 1.5 Use Labels Effectively

```yaml
metadata:
  labels:
    # Standard labels (Kubernetes recommended)
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp-prod
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: frontend
    app.kubernetes.io/part-of: myplatform
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/created-by: controller

    # Custom labels for selection
    app: myapp
    env: prod
    team: backend
    tier: frontend

# Use label selectors
spec:
  selector:
    matchLabels:
      app: myapp
      env: prod
```

---

## 2. Resource Management

### 2.1 Right-Size Your Resources

**How to find correct values:**

```bash
# 1. Deploy without limits, monitor usage
kubectl top pods --containers

# 2. Use VPA to recommend
kubectl describe vpa myapp-vpa | grep -A 5 "Target"

# 3. Set requests to 85th percentile
# 4. Set limits to 125-150% of requests
```

**Example Resource Sizing:**

| Component Type | Request | Limit | Ratio |
|----------------|---------|-------|-------|
| **API Server** | 100m CPU, 128Mi RAM | 200m CPU, 256Mi RAM | 2x |
| **Worker** | 500m CPU, 512Mi RAM | 1000m CPU, 1Gi RAM | 2x |
| **DB** | 1000m CPU, 2Gi RAM | 2000m CPU, 4Gi RAM | 2x |
| **Sidecar** | 50m CPU, 64Mi RAM | 100m CPU, 128Mi RAM | 2x |

### 2.2 Use HPA for Horizontal Scaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### 2.3 Use Pod Disruption Budgets

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 2  # At least 2 pods must be available
  # OR
  # maxUnavailable: 25%  # At most 25% can be down
  selector:
    matchLabels:
      app: myapp
```

---

## 3. Configuration Management

### 3.1 Use ConfigMaps for Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  # Key-value pairs
  database.url: "postgres://db:5432/mydb"
  cache.ttl: "3600"
  debug: "false"

  # File-like keys
  app.yaml: |
    server:
      port: 8080
      host: 0.0.0.0
    logging:
      level: info
      format: json
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: myapp:1.0
    # As environment variables
    envFrom:
    - configMapRef:
        name: app-config
    # Or mount as files
    volumeMounts:
    - name: config
      mountPath: /etc/config
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: app-config
```

### 3.2 Use Secrets for Sensitive Data

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  # Values must be base64 encoded
  password: cGFzc3dvcmQxMjM=
  api-key: YXBpLWtleS1zZWNyZXQ=
stringData:
  # Or use stringData for plain text (auto-encoded)
  tls.crt: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
```

### 3.3 Immutable ConfigMaps

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
immutable: true  # Cannot be updated after creation
data:
  config.yaml: |
    ...
```

**Benefits:**
- Prevents accidental updates
- Improves performance (no watch overhead)
- Forces versioning (create new instead of updating)

---

## 4. Security Best Practices

### 4.1 Use Pod Security Standards

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true      # Don't run as root
    runAsUser: 1000         # Specific user
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault  # Use default seccomp profile
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false  # Don't allow privilege escalation
      readOnlyRootFilesystem: true     # Read-only root filesystem
      capabilities:
        drop:
        - ALL                    # Drop all capabilities
        add:
        - NET_BIND_SERVICE       # Add only what's needed
      runAsUser: 1000
```

### 4.2 Use Network Policies

```yaml
# Default deny all
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
```

### 4.3 Use RBAC

```yaml
# Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
---
# Role (what can be done)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: config-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
---
# RoleBinding (who can do what)
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-config-reader
subjects:
- kind: ServiceAccount
  name: myapp-sa
roleRef:
  kind: Role
  name: config-reader
  apiGroup: rbac.authorization.k8s.io
```

### 4.4 Scan Images for Vulnerabilities

```bash
# Use Trivy
trivy image myapp:1.0

# Use in CI/CD
trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:1.0
```

---

## 5. Networking Best Practices

### 5.1 Use Services for Discovery

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: ClusterIP  # Default, cluster-internal
  selector:
    app: myapp
  ports:
  - name: http
    port: 80        # Service port
    targetPort: 8080 # Container port
    protocol: TCP
```

**DNS resolution:**
- `myapp.default.svc.cluster.local` (FQDN)
- `myapp.default.svc` (short)
- `myapp` (within same namespace)

### 5.2 Use Ingress for HTTP Routing

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

### 5.3 Use ReadinessProbes with Services

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      # Pod removed from service if probe fails
```

---

## 6. Monitoring Best Practices

### 6.1 Follow the RED Method

```promql
# Rate - Requests per second
sum(rate(http_requests_total{job="myapp"}[5m]))

# Errors - Error rate
sum(rate(http_requests_total{job="myapp",status=~"5.."}[5m])) /
sum(rate(http_requests_total{job="myapp"}[5m]))

# Duration - Latency percentiles
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket{job="myapp"}[5m])) by (le)
)
```

### 6.2 Follow the USE Method for Resources

```promql
# Utilization - Average usage
rate(container_cpu_usage_seconds_total{container="myapp"}[5m]) /
container_cpu_limit_seconds_total{container="myapp"}

# Saturation - How full
container_memory_working_set_bytes{container="myapp"} /
container_spec_memory_limit_bytes{container="myapp"}

# Errors - Errors accessing resources
rate(container_cpu_cfs_throttled_seconds_total{container="myapp"}[5m])
```

### 6.3 Alert on Causes, Not Symptoms

```yaml
# ❌ BAD: Alert on symptom
groups:
- name: bad
  rules:
  - alert: HighCPU
    expr: cpu_usage_percent > 80
    # What does this mean? What to do?

# ✅ GOOD: Alert on cause
groups:
- name: good
  rules:
  - alert: DatabaseConnectionPoolExhausted
    expr: db_connections_active / db_connections_max > 0.9
    for: 5m
    labels:
      severity: critical
      team: backend
    annotations:
      summary: "Database connection pool nearly exhausted"
      description: "{{ $value }}% of connections used"
      runbook: "https://runbooks.example.com/db-pool"
      impact: "API may fail to serve requests"
      action: "Check for connection leaks, consider increasing pool size"
```

---

## 7. Observability Best Practices

### 7.1 Use Structured Logging

```go
// ❌ BAD: Unstructured
log.Printf("User %s logged in at %s", user.ID, time.Now())

// ✅ GOOD: Structured
logger.WithFields(log.Fields{
    "event": "user_login",
    "user_id": user.ID,
    "timestamp": time.Now(),
    "ip": r.RemoteAddr,
}).Info("User logged in")
```

**Loki query pattern:**
```
{app="myapp"} |= `user_login` | json | user_id = "123"
```

### 7.2 Use Context Propagation for Tracing

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/trace"
)

func HandleRequest(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    span := trace.SpanFromContext(ctx)

    span.AddEvent("processing_started")
    // ... processing ...
    span.SetAttributes(
        attribute.String("user.id", userID),
        attribute.Int("items.count", len(items)),
    )
}
```

### 7.3 Define SLOs Before SLIs

```
# ❌ BAD: Measure everything, define SLO after
# We collect 500 metrics, then decide what's important

# ✅ GOOD: Define SLO first, then measure
SLO: 99.9% of API requests succeed within 500ms
|
├─ SLI 1: Success rate (target: 99.9%)
├─ SLI 2: Latency p95 (target: <500ms)
└─ SLI 3: Availability (target: 99.9%)

Then we ONLY measure:
  - request_count (success vs error)
  - request_duration
  - uptime
```

### 7.4 Use Error Budgets Wisely

```
SLO: 99.9% uptime
Error Budget: 0.1% = 43.2 minutes/month

Burn Rate Scenarios:
├─ 1x: 43.2 minutes to exhaust (1 month)
├─ 2x: 21.6 minutes to exhaust (2 weeks)
├─ 10x: 4.32 minutes to exhaust (1 day)
└─ 100x: 25.9 seconds to exhaust (1 hour!)

Alert: Page if burn rate >10x for >1 hour
```

---

## Checklist

### Deployment Checklist

- [ ] Uses Deployment, not bare Pod
- [ ] Resource requests and limits set
- [ ] All probes defined (startup, liveness, readiness)
- [ ] Security context configured
- [ ] RBAC with minimal permissions
- [ ] Network policy applied
- [ ] Secrets used for sensitive data
- [ ] Proper labels and annotations
- [ ] Pod Disruption Budget configured
- [ ] HPA configured for stateless services
- [ ] Image tag pinned (not :latest)
- [ ] Health check endpoints implemented
- [ ] Graceful shutdown implemented (preStop hook)
- [ ] Logs are structured
- [ ] Metrics exposed on /metrics
- [ ] Tracing instrumentation added

---

**See also:** `docs/ANTI_PATTERNS.md` for what NOT to do.
