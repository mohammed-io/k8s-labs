# Solution: Monitoring Basics with Prometheus

## Complete Manifests

### ServiceMonitor
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: myapp
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
  namespaceSelector:
    any: true
```

### PrometheusRule for Recording
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-recording-rules
  namespace: monitoring
spec:
  groups:
  - name: myapp.rules
    interval: 30s
    rules:
    - record: job:http_requests_total:rate1m
      expr: rate(http_requests_total[1m])
    - record: job:http_errors_total:rate5m
      expr: rate(http_errors_total[5m])
    - record: job:http_request_duration:p95
      expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### PrometheusRule for Alerting
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

## Setup Commands

```bash
# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (includes Prometheus, Grafana, etc.)
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Verify
kubectl get pods -n monitoring
kubectl get servicemonitors -n monitoring
```

## Key Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `http_requests_total` | Counter | Total HTTP requests |
| `http_errors_total` | Counter | Total HTTP errors |
| `http_request_duration_seconds` | Histogram | Request latency |
| `up` | Gauge | Service availability (1=up, 0=down) |

## Query Examples

```promql
# Request rate (RPS)
rate(http_requests_total[5m])

# Error rate
rate(http_errors_total[5m]) / rate(http_requests_total[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Service availability
up{job="myapp"}
```
