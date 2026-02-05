# Monitoring & Observability Concepts

**Deep understanding of Prometheus, Grafana, OpenTelemetry, and SRE practices.**

---

## Table of Contents

1. [Observability Pillars](#1-observability-pillars)
2. [Prometheus Architecture](#2-prometheus-architecture)
3. [Metrics Types](#3-metrics-types)
4. [PromQL Deep Dive](#4-promql-deep-dive)
5. [Alerting Strategy](#5-alerting-strategy)
6. [Grafana Dashboards](#6-grafana-dashboards)
7. [OpenTelemetry](#7-opentelemetry)
8. [SRE Methodologies](#8-sre-methodologies)

---

## 1. Observability Pillars

### The Three Pillars

```
                    ┌─────────────────────────────┐
                    │      OBSERVABILITY           │
                    ├─────────────────────────────┤
                    │                             │
      ┌───────────┴─────────────┐              │
      │                           │              │
┌─────▼────┐  ┌─────────┐  ┌───────▼──────┐
│ Metrics  │  │  Logs   │  │   Traces    │
│          │  │         │  │              │
│ Numbers  │  │ Records │  │ Journeys    │
│ over     │  │ with   │  │ across       │
│ time     │  │ context │  │ services    │
└──────────┘  └─────────┘  └──────────────┘
```

### When to Use Each

| Pillar | Best For | Example Question |
|--------|----------|-------------------|
| **Metrics** | Trending, alerting | "Are we getting slower?" |
| **Logs** | Debugging, audit | "Why did this error happen?" |
| **Traces** | Optimization | "Where is the latency coming from?" |

### Correlation

```
Request Flow:
User → Load Balancer → Web App → API → Database

Metrics:
  lb_latency: 50ms
  web_latency: 200ms
  api_latency: 150ms
  db_latency: 100ms

Total: 500ms

Logs:
  [INFO] Processing request user=123
  [ERROR] Timeout connecting to cache

Traces:
  ├─ HTTP GET /api/users/123
  │  ├─ DB query users
  │  │  ├─ Cache miss
  │  │  └─ DB query (120ms)
  │  └─ Response 200

Combined Insight:
  Cache timeout caused extra DB query
  Fix: Increase cache TTL or add retries
```

---

## 2. Prometheus Architecture

### Pull-Based Model

```
                ┌─────────────────────────────────────┐
                │          Services                   │
                ├─────────────────────────────────────┤
                │                             │         │
          ┌─────▼──────┐                 ┌──────▼─────┐
          │   Web App  │                 │   API      │
          │   /metrics  │                 │   /metrics │
          └─────┬──────┘                 └──────┬─────┘
                │                            │
                │  Pull (scrape)             │  Pull
                │                            │
          ┌─────▼────────────────────────────▼─────┐
          │         Prometheus                  │
          │  (TSDB: Time Series Database)      │
          │                                   │
          │  ┌─────────────────────────────┐  │
          │  │        TSDB                  │  │
          │  │  ┌─────────┬─────────┐     │  │
          │  │  │ Metrics │ Labels  │     │  │
          │  │  └─────────┴─────────┘     │  │
          │  └─────────────────────────────┘  │
          └─────┬─────────────────────────────┘
                │
                │ Query
                ▼
          ┌─────────────┐
          │   Grafana   │
          │ (Visualize)  │
          └─────────────┘
```

### Key Components

| Component | Role |
|-----------|------|
| **Prometheus Server** | Scrapes and stores metrics |
| **Pushgateway** | For short-lived jobs (batch) |
| **Alertmanager** | Routes and deduplicates alerts |
| **Node Exporter** | Host metrics (CPU, mem, disk) |
| **Kube-State-Metrics** | K8s object metrics |
| **cAdvisor** | Container metrics |

### Scrape Configuration

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        target_label: app
      - source_labels: [__meta_kubernetes_pod_namespace]
        target_label: namespace
      - regex: __meta_kubernetes_pod_label_(.+)
        action: labelmap
```

---

## 3. Metrics Types

### Prometheus Metric Types

```promql
# Counter: Monotonically increasing
http_requests_total{endpoint="/api/users"}

# Gauge: Can go up or down
memory_usage_bytes{pod="app-123"}
queue_length{service="api"}

# Histogram: Distribution sampling
http_request_duration_seconds_bucket{le="0.1"}

# Summary: Distributed histogram
response_time{quantile="0.99"}
```

### Counter

```promql
# Raw counter
http_requests_total

# Rate of change
rate(http_requests_total[5m])

# Total increase over time
increase(http_requests_total[1h])

# Per-second rate (for counters)
irate(http_requests_total[5m])
```

### Histogram

```yaml
# Application emits histogram
Histogram: http_request_duration_seconds
  Bucket: 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10
```

```promql
# Query bucket counts
http_request_duration_seconds_bucket{le="0.1"}

# Calculate quantile
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[5m])
)

# Average request duration
rate(http_request_duration_seconds_sum[5m])
  /
rate(http_request_duration_seconds_count[5m])
```

### Summary

```promql
# Pre-calculated quantiles from application
api_response_time{quantile="0.5"}
api_response_time{quantile="0.9"}
api_response_time{quantile="0.99"}
```

### Metric Naming Conventions

```
<metric_name>_<unit>           # Use base units
<metric_name>_total            # Counters only
<metric_name>_sum             # Histogram sum
<metric_name>_count           # Histogram count
<metric_name>_bucket          # Histogram buckets

# Good
http_requests_total
http_request_duration_seconds
memory_usage_bytes

# Bad
httpRequests                  # Mixed case
http_request_seconds          # Ambiguous
mem_usage                     # Abbreviation
```

---

## 4. PromQL Deep Dive

### Instant Selectors

```promql
# All metrics named http_requests_total
http_requests_total

# With label matching
http_requests_total{job="api"}

# Regex match
http_requests_total{job=~"api.*"}
http_requests_total{job!~".*-test"}

# Multiple labels
http_requests_total{job="api",env="prod"}

# Not equal
http_requests_total{env!="test"}
```

### Range Selectors

```promql
# Last 5 minutes
http_requests_total[5m]

# Last hour
http_requests_total[1h]

# With offset (time travel)
http_requests_total offset 1h
```

### Operators

```promql
# Arithmetic
http_requests_total * 0.5

# Comparison
http_requests_total > 100
http_requests_total == 0

# Logical
http_requests_total > 100 and env="prod"
http_requests_total < 50 or http_errors_total > 10

# Regex matching
job =~ "web.*"
job !~ "test-.*"
```

### Aggregation

```promql
# Sum all series
sum(http_requests_total)

# Sum by label
sum by (job) (http_requests_total)

# Average
avg(http_requests_total)

# Count of series
count(http_requests_total)

# Max/Min
max(memory_usage_bytes)
min(memory_usage_bytes)

# Standard deviation
stddev(http_request_duration_seconds)

# Variance
variance(http_request_duration_seconds)

# Bottom/Top
bottomk(5, http_requests_total)
topk(5, http_requests_total)
```

### Rate Functions

```promql
# Per-second rate (for counters)
rate(http_requests_total[5m])

# Per-second irate (for counters, handles resets)
irate(http_requests_total[5m])

# Increase over time
increase(http_requests_total[1h])

# Changes over time
changes(http_requests_total[1h])
```

### Time Functions

```promql
# Offset (compare with past)
http_requests_total / http_requests_total offset 1h

# Prediction
predict_linear(http_requests_total[1h], 3600)

# Time delta
time()
timestamp()
```

---

## 5. Alerting Strategy

### Alerting Principles

```
Good Alert:
├─ Actionable (tells you what to do)
├─ Contains runbook link
├─ Describes symptom AND cause
├─ Includes severity
└─ Has defined SLO impact

Bad Alert:
├─ "High CPU" (not actionable)
├─ No runbook
├─ Alert on symptom (not root cause)
├─ No severity
└─ No context
```

### Alert Rule Structure

```yaml
groups:
  - name: api
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status="500"}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "High error rate on API"
          description: "Error rate is {{ $value }} errors/sec"
          runbook: "https://wiki.company.com/runbooks/api-errors"
          dashboard: "https://grafana.company.com/d/api"
          slo: "99.9% of requests succeed"
```

### Alert States

```
Pending ──► Firing ──► (Resolved)
   ▲              │
   │              └─► (Silenced)
   │
   └─► Inhibited

Pending: Alert condition met, waiting for `for` duration
Firing:  Alert active, being sent to Alertmanager
Silenced: Alert muted by someone
Inhibited: Alert suppressed due to dependencies
```

### Alert Routing (Alertmanager)

```yaml
# Alertmanager config
routes:
  - match:
      severity: critical
    receiver: pagerduty
    group_by: [alertname, cluster]
    group_wait: 10s
    repeat_interval: 12h

  - match:
      severity: warning
    receiver: slack
    group_by: [team, alertname]

  - match:
      severity: info
    receiver: email
    group_wait: 5m
```

---

## 6. Grafana Dashboards

### Dashboard Design Principles

```
Good Dashboard:
├─ One purpose (e.g., "API Performance")
├─ Clear SLO indicator
├─ Start time selector
├─ Variable selectors (env, service)
├─ Signal panel (top panel, big numbers)
└─ Context panels (logs, traces links)

Bad Dashboard:
├─ Everything but the kitchen sink
├─ No clear purpose
├─ No time range visible
├─ No variables (hardcoded env)
└─ Mixed time ranges
```

### Essential Panels

1. **Signal Panel** (Top)
   - SLO status
   - Error budget remaining
   - Request rate (R in RED)

2. **Latency** (E in RED)
   - p50, p95, p99
   - Over time graph

3. **Error Rate** (E in RED)
   - 5xx rate
   - 4xx rate

4. **Traffic** (Golden Signal)
   - Requests per second
   - Active connections

5. **Saturation** (USE Method)
   - CPU % (Utilization)
   - Memory % (Saturation)
   - Queue depth

### Panel Types

```promql
# Single Stat (big number)
sum(rate(http_requests_total[5m]))

# Time series graph
rate(http_requests_total{job="api"}[5m])

# Gauge
memory_usage_bytes{pod="app-123"}

# Stat table
topk(10, rate(http_requests_total[5m]))

# Heatmap
rate(http_requests_total[5m])
```

### Dashboard Variables

```yaml
# Variables
datasource: prometheus
  env: query_label(app)
  pod: query_label(pod)
  instance: query_label(instance)

# Use in queries
rate(http_requests_total{app="$env", pod="$pod"}[5m])
```

---

## 7. OpenTelemetry

### OTEL Architecture

```
                    Application
                         │
                         ▼
              ┌─────────────────────┐
              │   OTEL Instrument  │
              │                     │
              │  Metrics   Logs     │
              │    |        |       │
              │    ▼        ▼       │
              └────┬───────────┴───────┘
                   │
                   ▼
            ┌────────────────┐
            │ OTEL Collector │
            │                │
            │  Process       │
            │  Batch         │
            │  Export        │
            └────┬────────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
   ┌─────────┐      ┌─────────┐
   │Prometheus│      │  Loki    │
   │ (metrics)│      │  (logs)  │
   └─────────┘      └─────────┘
```

### Instrumentation

```go
// Go with OTEL
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/prometheus"
)

func init() {
    exporter, _ := prometheus.New()
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
    )
    otel.SetTracerProvider(tp)
}

// Create a span
tracer := otel.Tracer("app")
ctx, span := tracer.Start(ctx, "operation")
defer span.End()

// Add attributes
span.SetAttributes(
    attribute.String("http.method", "GET"),
    attribute.String("http.url", "/api/users"),
)
```

### OTEL Collector Config

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:

exporters:
  prometheus:
    endpoint: "localhost:9090"
  logging:
    loglevel: debug
```

---

## 8. SRE Methodologies

### RED Method (for Services)

```
Focus on: Rate, Errors, Duration

Rate:
  └─ Requests per second
  └─ Demand measurement

Errors:
  └─ Failed requests / total requests
  └─ Error budget burn rate

Duration:
  └─ Request latency (p50, p95, p99)
  └─ User experience
```

### USE Method (for Resources)

```
Focus on: Utilization, Saturation, Errors

Utilization:
  └─ Average resource usage
  └─ "Are we wasting money?"

Saturation:
  └─ How full is the resource?
  └─ "Are we at capacity?"

Errors:
  └─ Errors accessing the resource
  └─ "Is the resource failing?"
```

### The Four Golden Signals

| Signal | Description | PromQL Example |
|--------|-------------|---------------|
| **Latency** | Time to service requests | `rate(http_duration_sum[5m])/rate(http_duration_count[5m])` |
| **Traffic** | Request load | `sum(rate(http_requests_total[5m]))` |
| **Errors** | Failed requests | `rate(http_requests_total{status="5xx"}[5m])` |
| **Saturation** | How full is the system | `cpu_usage_percent / cpu_capacity` |

### SLO Calculation

```
Error Budget = 1 - (SLO / 100)

Example:
SLO: 99.9% uptime (success rate)
Error Budget = 100% - 99.9% = 0.1% (43.2 minutes/month)

Burn Rate:
├─ Current error rate: 0.5%
├─ Burn rate: 0.5% - 0.1% = 0.4%/hour
└─ Time to zero error budget: 0.1% / 0.4% = 15 minutes

Alert: If error budget burns >50% in 1 week
```

---

## Monitoring Anti-Patterns

### ❌ Don't Do This

```promql
# Alert on raw CPU without context
cpu_usage_percent > 80

# Monitor everything (noise)
up{job=~".*"}

# Alert on symptoms not causes
high_latency  # Without knowing WHY

# Dashboards without SLO
"What's our performance?"  # No target defined

# Alerts without runbooks
"Alert: High memory"  # What do I do?
```

### ✅ Do This Instead

```promql
# Alert with context
cpu_usage_percent{instance="db-0"} > 80
  and on (instance) (predict_linear(cpu_usage_percent[1h], 3600) > 90)

# Alert on cause
connection_failure_rate > 0.01

# SLO-based dashboards
Error Budget Remaining: 5.2 days
SLI: 99.95% (current: 99.97%)
Burn Rate: 0.01%/day

# Alert with runbook
Alert: Database saturation
Runbook: https://wiki.company.com/db-saturation
  1. Check read replica lag
  2. Review slow queries
  3. Consider adding read replica
```

---

## Key Takeaways

| Concept | Key Insight |
|---------|-------------|
| **Metrics** | Good for alerting, dashboards |
| **Logs** | Good for debugging, root cause |
| **Traces** | Good for optimization, distributed systems |
| **Prometheus** | Pull-based, time series DB |
| **RED Method** | Rate, Errors, Duration for services |
| **USE Method** | Utilization, Saturation, Errors for resources |
| **SLO** | Target you commit to users |
| **Alert on causes** | Not symptoms |
| **Runbooks** | Every alert needs one |
| **Error Budget** | Time remaining before SLO breach |

---

**Next:** See `docs/BEST_PRACTICES.md` for production guidance.
