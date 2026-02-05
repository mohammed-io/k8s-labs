# Kubernetes & Monitoring - Anti-Patterns

**Common mistakes to avoid. Learn from others' failures.**

---

## Table of Contents

1. [Kubernetes Anti-Patterns](#1-kubernetes-anti-patterns)
2. [Monitoring Anti-Patterns](#2-monitoring-anti-patterns)
3. [Alerting Anti-Patterns](#3-alerting-anti-patterns)
4. [Scaling Anti-Patterns](#4-scaling-anti-patterns)
5. [Architecture Anti-Patterns](#5-architecture-anti-patterns)

---

## 1. Kubernetes Anti-Patterns

### 1.1 Using Bare Pods

```yaml
# ❌ ANTI-PATTERN: Bare Pod
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  containers:
  - name: web
    image: nginx:1.25
```

**Why it's bad:**
- No self-healing (if pod dies, it stays dead)
- No rolling updates
- No scaling
- Manual recreation required

**Fix:** Use Deployments instead

---

### 1.2 Not Setting Resource Limits

```yaml
# ❌ ANTI-PATTERN: No resources defined
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:1.0
        # No resources section!
```

**Why it's bad:**
- Pod can consume all node resources (noisy neighbor)
- Scheduler can't make intelligent decisions
- OOMKill at unpredictable times
- No QoS class (BestEffort = first to be killed)

**Fix:** Always set requests and limits

---

### 1.3 Using :latest Image Tags

```yaml
# ❌ ANTI-PATTERN: Using latest tag
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest  # Will change unexpectedly!
```

**Why it's bad:**
- Can't rollback to specific version
- Unexpected behavior when image updates
- Breaks immutable infrastructure
- Makes debugging difficult

**Fix:** Pin specific versions
```yaml
image: myapp:1.0.5  # Or use image digest
```

---

### 1.4 Missing Health Probes

```yaml
# ❌ ANTI-PATTERN: No probes
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:1.0
        # No liveness probe - deadlocked pods never restart
        # No readiness probe - broken pods receive traffic
```

**Why it's bad:**
- Deadlocked containers never restart
- Starting containers receive traffic before ready
- No graceful degradation
- Downtime during deployments

**Fix:** Always define liveness and readiness probes

---

### 1.5 Running as Root

```yaml
# ❌ ANTI-PATTERN: Running as root
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: myapp:1.0
    # Runs as root by default
    securityContext: {}
```

**Why it's bad:**
- Container escape = root on host
- Greater attack surface
- Violates principle of least privilege
- Security scanners will flag it

**Fix:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
```

---

### 1.6 Secrets in ConfigMaps

```yaml
# ❌ ANTI-PATTERN: Sensitive data in ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_password: "SuperSecret123"  # Visible in plain text!
  api_key: "sk_live_abc123"
```

**Why it's bad:**
- Not encrypted at rest (by default)
- Visible in etcd
- Visible in kubectl commands
- Logged in audit trails

**Fix:** Use Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  database_password: "SuperSecret123"
```

---

### 1.7 Hardcoded Configuration

```yaml
# ❌ ANTI-PATTERN: Hardcoded values
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:1.0
        env:
        - name: DATABASE_URL
          value: "postgres://prod-db.example.com:5432/mydb"  # Hardcoded!
        - name: API_KEY
          value: "abc123"  # Hardcoded secret!
```

**Why it's bad:**
- Can't change without redeployment
- Environment-specific config in code
- Secrets exposed in version control
- Can't promote across environments

**Fix:** Use ConfigMaps and Secrets
```yaml
env:
- name: DATABASE_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database_url
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: api_key
```

---

### 1.8 Giant Container Images

```dockerfile
# ❌ ANTI-PATTERN: Giant image
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    nodejs \
    npm \
    gcc \
    make \
    curl \
    wget \
    vim \
    # ... many more packages

COPY . .
RUN pip install -r requirements.txt
RUN npm install
```

**Why it's bad:**
- Longer pull times
- More attack surface
- Wasted storage
- Slower deployments

**Fix:** Use minimal base images
```dockerfile
FROM alpine:3.19
# OR
FROM golang:1.21-alpine AS builder
# Multi-stage builds to exclude build dependencies
FROM scratch
COPY --from=builder /app /app
```

---

## 2. Monitoring Anti-Patterns

### 2.1 Monitoring Everything

```promql
# ❌ ANTI-PATTERN: Measure everything
up  # All targets
kube_pod_info  # All pods
container_memory_rss  # All containers
node_cpu_seconds_total  # All nodes
# ... 500+ more metrics
```

**Why it's bad:**
- Metric explosion (high cardinality)
- Expensive to store and query
- Can't find what matters
- Noise obscures signal

**Fix:** Start with Golden Signals
```promql
# Only what you need for SLOs
rate(http_requests_total{job="myapp"}[5m])
rate(http_requests_total{job="myapp",status=~"5.."}[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="myapp"}[5m]))
```

---

### 2.2 Alerting on Symptoms Instead of Causes

```yaml
# ❌ ANTI-PATTERN: Alert on symptom
groups:
- name: bad
  rules:
  - alert: HighCPU
    expr: cpu_usage_percent > 80
    # So what? What do I do?
```

**Why it's bad:**
- Doesn't tell you what's wrong
- Doesn't tell you what to do
- False positives during normal load
- Alert fatigue

**Fix:** Alert on cause
```yaml
- alert: DatabaseSlowQuerySpike
  expr: rate(db_slow_queries_total[5m]) > 10
  annotations:
    summary: "Database slow queries spiked"
    runbook: "https://runbooks.example.com/db-slow"
    action: "Check query performance, analyze EXPLAIN plans"
```

---

### 2.3 Dashboard Without Purpose

```yaml
# ❌ ANTI-PATTERN: Kitchen sink dashboard
# Everything but the kitchen sink
panels:
  - CPU
  - Memory
  - Disk
  - Network
  - 50 application metrics
  - 20 infra metrics
  - Kubernetes events
  - Log streams
  # ... more
```

**Why it's bad:**
- Can't find what matters
- No clear SLO indicator
- Mixed time ranges
- Not actionable

**Fix:** One dashboard = one purpose
```
┌─────────────────────────────────────┐
│     API Performance Dashboard        │
│                                     │
│  SLO Status: 99.95% (Target: 99.9%) │ ← Signal
│  Error Budget: 5.2 days remaining   │
│                                     │
│  Request Rate ┌──────────────────┐   │
│  ────────────►│ Graph            │   │
│              └──────────────────┘   │
│                                     │
│  p95 Latency  ┌──────────────────┐   │
│  ────────────►│ Graph            │   │
│              └──────────────────┘   │
│                                     │
│  Error Rate   ┌──────────────────┐   │
│  ────────────►│ Graph            │   │
│              └──────────────────┘   │
└─────────────────────────────────────┘
```

---

### 2.4 Using Average for Latency

```promql
# ❌ ANTI-PATTERN: Average latency
avg(http_request_duration_seconds) or
rate(http_request_duration_seconds_sum[5m]) /
rate(http_request_duration_seconds_count[5m])
```

**Why it's bad:**
- Hides tail latency
- One slow request = 100 fast requests
- Users care about p95/p99, not average
- Misses real user experience

**Fix:** Use percentiles
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

**Visual:**
```
Request times: [10ms, 12ms, 11ms, 15ms, 5000ms]
Average: 1009.6ms  ← Misleading!
p95: 5000ms  ← What most users experience
p99: 5000ms
```

---

### 2.5 Short Retention for Critical Data

```yaml
# ❌ ANTI-PATTERN: Short retention
# Prometheus retention: 15 days
# Can't investigate incidents from last month
# Can't see seasonal patterns
# Can't do year-over-year analysis
```

**Why it's bad:**
- Can't investigate old incidents
- Miss long-term trends
- No historical baseline
 Compliance issues

**Fix:** Tiered storage
```
Hot storage (Prometheus):  15 days  → Fast queries
Warm storage (Thanos/Cortex): 1 year → Acceptable speed
Cold storage (S3/GCS):     7 years → Compliance/archive
```

---

## 3. Alerting Anti-Patterns

### 3.1 Alerting on Every Spike

```yaml
# ❌ ANTI-PATTERN: Hair-trigger alerts
groups:
- name: jumpy
  rules:
  - alert: HighErrorRate
    expr: error_rate > 0  # Alert on ANY error!
    # No for: duration
    # No threshold consideration
```

**Why it's bad:**
- Alerts on transient blips
- Pager fatigue
- People stop paying attention
- Real issues missed in noise

**Fix:** Add threshold and duration
```yaml
- alert: HighErrorRate
  expr: error_rate > 0.05  # 5% error rate
  for: 5m  # Sustained for 5 minutes
  # Only page if this is a real problem
```

---

### 3.2 No Alert Routing

```yaml
# ❌ ANTI-PATTERN: Everything goes to everyone
groups:
- name: noise
  rules:
  - alert: EverythingBroken
    # Every alert goes to the same channel
    # Everyone gets paged for everything
```

**Why it's bad:**
- Wrong people get notified
- Everyone ignores everything
- Can't escalate properly
- No ownership

**Fix:** Route by severity/team
```yaml
# Critical → PagerDuty (on-call)
# Warning → Slack (team channel)
# Info → Email (daily digest)
```

---

### 3.3 Missing Runbooks

```yaml
# ❌ ANTI-PATTERN: Mystery alerts
- alert: SomethingBadHappened
  expr: bad_things > 0
  annotations:
    summary: "Something is bad"
    # No runbook link
    # No action steps
    # No context
```

**Why it's bad:**
- What do I do?
- Who owns this?
- What's the impact?
- Panic and confusion

**Fix:** Include actionable context
```yaml
- alert: DatabaseConnectionPoolExhausted
  annotations:
    summary: "Database connection pool nearly full"
    description: "{{ $value }}% of connections used"
    runbook: "https://runbooks.example.com/db-pool"
    impact: "API may fail to serve requests"
    action: "1. Check for connection leaks\n2. Consider increasing pool size\n3. Check database health"
    team: "backend"
    escalation: "https://oncall.example.com/backend"
```

---

### 3.4 No Alert Priority

```yaml
# ❌ ANTI-PATTERN: Everything is critical
# All alerts treated equally
# Can't distinguish "world on fire" from "mild issue"
```

**Why it's bad:**
- Can't prioritize response
- Everything feels urgent
- Desensitization
- Burnout

**Fix:** Use severity levels
```yaml
P0 (Critical): Page immediately, wake people up
  - Service down
  - Data loss
  - Security breach

P1 (High): Page within 5 minutes
  - Degraded performance
  - SLO at risk

P2 (Medium): Slack notification, respond within hour
  - Elevated error rate
  - Resource pressure

P3 (Low): Email, next business day
  - Certificate expiring in 30 days
  - Disk usage warning
```

---

## 4. Scaling Anti-Patterns

### 4.1 Setting HPA min = max

```yaml
# ❌ ANTI-PATTERN: No actual scaling
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  minReplicas: 3
  maxReplicas: 3  # Same as min!
  # HPA will never scale
```

**Why it's bad:**
- No auto-scaling happens
- Wasted HPA controller resources
- False sense of scalability

**Fix:** Allow room to scale
```yaml
minReplicas: 2
maxReplicas: 10  # Allow 5x growth
```

---

### 4.2 Scaling on CPU Alone

```yaml
# ❌ ANTI-PATTERN: Only CPU-based scaling
spec:
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  # But the bottleneck might be:
  # - Database connections
  # - API rate limits
  # - Queue depth
  # - Memory
```

**Why it's bad:**
- CPU might be fine but service is slow
- Scaling doesn't help the real bottleneck
- Wastes resources

**Fix:** Scale on business metrics
```yaml
metrics:
- type: Resource
  resource:
    name: cpu
- type: Pods
  pods:
    metric:
      name: active_requests
    target:
      type: AverageValue
      averageValue: "1000"
- type: External
  external:
    metric:
      name: rabbitmq_queue_messages
    target:
      type: AverageValue
      averageValue: "100"
```

---

### 4.3 Using HPA for Stateful Applications

```yaml
# ❌ ANTI-PATTERN: HPA on databases
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: postgres-hpa
spec:
  scaleTargetRef:
    kind: StatefulSet
    name: postgres
  # Databases don't scale like this!
```

**Why it's bad:**
- Data consistency issues
- Storage attached to specific pods
- Connection strings change
- Databases need special scaling

**Fix:** Use proper database scaling
```
PostgreSQL: Use connection pooling (PgBouncer), read replicas
MongoDB: Use sharding, replica sets
Redis: Use Redis Cluster
```

---

### 4.4 Scaling Too Fast

```yaml
# ❌ ANTI-PATTERN: Aggressive scaling
spec:
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0  # No wait
      policies:
      - type: Percent
        value: 500  # 5x instantly!
        periodSeconds: 15
```

**Why it's bad:**
- Can overshoot actual need
- Expensive (cloud bill)
- Can trigger downstream issues
- Creates "scaling oscillation"

**Fix:** Be conservative
```yaml
scaleUp:
  stabilizationWindowSeconds: 60  # Wait 1 minute
  policies:
  - type: Percent
    value: 100  # Max 2x per period
    periodSeconds: 60
  - type: Pods
    value: 4   # Or max 4 pods
    periodSeconds: 60
  selectPolicy: Min  # Choose the smaller change
```

---

## 5. Architecture Anti-Patterns

### 5.1 God Pods (Monolithic Containers)

```yaml
# ❌ ANTI-PATTERN: Everything in one container
spec:
  containers:
  - name: everything
    image: myapp:1.0  # Runs app + nginx + redis + cron
    # Single container doing too much
```

**Why it's bad:**
- Can't scale components independently
- All or nothing updates
- Resource allocation inefficient
- Hard to debug

**Fix:** Separate concerns
```
Pod: App container + Nginx sidecar
Deployment: App (scales separately)
StatefulSet: Redis (separate scaling)
CronJob: Scheduled tasks
```

---

### 5.2 Tight Coupling Between Services

```go
// ❌ ANTI-PATTERN: Hard dependencies
func ProcessOrder(order Order) error {
    // Direct call - what if Service B is down?
    resp := httpClient.Post("http://service-b/api", order)
    // Direct call - what if Database is down?
    db.Save(order)
}
```

**Why it's bad:**
- Cascading failures
- No fault isolation
- Can't deploy independently
    - Testing is hard

**Fix:** Add resilience
```go
func ProcessOrder(order Order) error {
    // Use circuit breaker
    if !breaker.CanProceed() {
        return fallback(order)  // Graceful degradation
    }

    // Use message queue for decoupling
    messageQueue.Publish("orders", order)

    return nil
}
```

---

### 5.3 Missing Timeouts

```go
// ❌ ANTI-PATTERN: No timeout
resp, err := http.Get("http://slow-service/api")
// Can hang forever!
```

**Why it's bad:**
- Goroutine leaks
- Resource exhaustion
- Cascading delays
- No backpressure

**Fix:** Always set timeouts
```go
client := &http.Client{
    Timeout: 5 * time.Second,
}
resp, err := client.Get("http://slow-service/api")
```

---

### 5.4 Synchronous Cross-Datacenter Calls

```
┌─────────────────┐                    ┌─────────────────┐
│   DC1 (US-East) │                    │   DC2 (US-West) │
│                 │   HTTP Request     │                 |
│  ┌───────────┐  │ ─────────────────► │  ┌───────────┐  │
│  │ Service A │  │                    │  │ Service B │  │
│  └───────────┘  │ ◄───────────────── │  └───────────┘  │
│                 │    (slow response)  │                 |
└─────────────────┘                    └─────────────────┘
```

**Why it's bad:**
- Inter-DC latency (~50-100ms)
- Dependency on remote DC
- Double failure surface
- Expensive traffic

**Fix:** Async messaging
```
┌─────────────────┐
│   DC1 (US-East) │
│  ┌───────────┐  │   Kafka Topic   ┌─────────────────┐
│  │ Service A │──┼────────────────►│   DC2 (US-West) │
│  └───────────┘  │                  │  ┌───────────┐  │
│                 │                  │  │ Service B │──┼──► Process
└─────────────────┘                  │  └───────────┘  │
                                     └─────────────────┘
```

---

## Summary: Anti-Pattern Detection Checklist

Review your configurations for these warning signs:

- [ ] Bare Pods without Deployments
- [ ] Missing resource requests/limits
- [ ] Using `:latest` image tags
- [ ] No health probes defined
- [ ] Running containers as root
- [ ] Secrets in ConfigMaps
- [ ] Hardcoded configuration values
- [ ] Giant container images (>500MB)
- [ ] Monitoring everything (metric explosion)
- [ ] Alerting on symptoms, not causes
- [ ] Dashboards without clear purpose
- [ ] Using averages for latency
- [ ] Hair-trigger alerts (no duration)
- [ ] No runbooks with alerts
- [ ] HPA min = max (no actual scaling)
- [ ] Scaling on CPU alone
- [ ] HPA on stateful apps
- [ ] God pods doing too much
- [ ] Tight coupling between services
- [ ] Missing timeouts on external calls

---

**Remember:** The best anti-pattern is the one you catch before production.
