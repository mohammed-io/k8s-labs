# Step 2: Alerting Rules and PromQL

---

## Understanding Alerting Rules

Alerting rules define conditions that trigger alerts when certain thresholds are breached.

### Alert Structure

```yaml
- alert: HighErrorRate
  expr: rate(http_errors_total[5m]) > 0.01
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High error rate detected"
    description: "Error rate is {{ $value | humanizePercentage }}"
```

| Field | Purpose |
|-------|---------|
| **alert** | Alert name |
| **expr** | PromQL expression to evaluate |
| **for** | Duration before alert fires |
| **labels** | Additional labels for routing |
| **annotations** | Human-readable details |

### Alert States

| State | Meaning |
|-------|---------|
| **Inactive** | Condition not met |
| **Pending** | Condition met, waiting for `for` duration |
| **Firing** | Alert is active and firing |

## Creating Alerting Rules

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-alerting-rules
  namespace: monitoring
spec:
  groups:
  - name: myapp.alerts
    rules:
    - alert: HighErrorRate
      expr: rate(http_errors_total[5m]) > 0.01
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value | humanizePercentage }}"
    
    - alert: HighLatency
      expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High latency detected"
        description: "P95 latency is {{ $value }}s"
    
    - alert: ServiceDown
      expr: up{job="myapp"} == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Service is down"
        description: "Myapp has been down for more than 2 minutes"
```

## PromQL Basics

PromQL is Prometheus's query language for selecting and aggregating time series data.

### Common Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `rate()` | Per-second rate over time | `rate(http_requests_total[5m])` |
| `sum()` | Aggregate across labels | `sum(rate(http_requests_total[5m]))` |
| `histogram_quantile()` | Calculate percentiles | `histogram_quantile(0.95, ...)` |
| `avg()` | Average value | `avg(node_cpu_seconds_total)` |

### Useful Queries

```promql
# Request rate (requests per second)
rate(http_requests_total[5m])

# Error rate as percentage
rate(http_errors_total[5m]) / rate(http_requests_total[5m]) * 100

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Request rate by status code
sum by (status) (rate(http_requests_total[5m]))

# Top 5 endpoints by traffic
topk(5, sum by (path) (rate(http_requests_total[5m])))
```

## Your Task

1. Create a `PrometheusRule` with alerting rules for:
   - High error rate (> 1%)
   - High latency (P95 > 500ms)
   - Service down

2. Apply and verify:
   ```bash
   kubectl apply -f alerting-rules.yaml
   kubectl get prometheusrule -n monitoring
   ```

3. Check alerts in Prometheus UI:
   ```bash
   kubectl port-forward svc/kube-prometheus-prometheus -n monitoring 9090:9090
   # Open http://localhost:9090/alerts
   ```

---

## Quick Check

1. What's the purpose of the `for` field in an alert? (Specifies how long the condition must be true before the alert fires, preventing alerts from transient issues)

2. What's the difference between Pending and Firing states? (Pending means the condition is met but the `for` duration hasn't elapsed; Firing means the alert is active)

3. What does `rate()` do in PromQL? (Calculates the per-second rate of a counter metric over a specified time window)

4. How do you calculate P95 latency? (Use histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])))

5. What's the `up` metric used for? (Indicates if a scrape target is reachable - 1 means up, 0 means down)

---

**Continue to `solution.md`**
