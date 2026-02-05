# Step 1: Prometheus and ServiceMonitor

---

## Prometheus Operator

The Prometheus Operator simplifies running Prometheus on Kubernetes with CRDs:

| CRD | Purpose |
|-----|---------|
| **Prometheus** | Defines Prometheus deployment |
| **ServiceMonitor** | Configures scrape targets |
| **PodMonitor** | Scrape pods directly |
| **AlertmanagerConfig** | Alert routing |

## ServiceMonitor

ServiceMonitor tells Prometheus which services to scrape:

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

## Exposing Metrics in Your App

Add `/metrics` endpoint to your application:

```go
// Go example with prometheus/client_golang
import "github.com/prometheus/client_golang/prometheus/promhttp"

http.Handle("/metrics", promhttp.Handler())
```

Or use a sidecar:

```yaml
spec:
  containers:
  - name: app
    image: myapp
  - name: exporter
    image: prom/statsd-exporter
```

## Recording Rules

Pre-compute expensive queries:

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
```

---

## Quick Check

1. What does a ServiceMonitor do? (Defines a set of targets for Prometheus to scrape, using Kubernetes service labels to discover pods)

2. What's the /metrics endpoint format? (Prometheus text exposition format - simple line-based text format with metric names, labels, and values)

3. Why use recording rules? (To pre-compute frequently used or expensive queries, making dashboards and alerts faster)

4. What's the difference between ServiceMonitor and PodMonitor? (ServiceMonitor scrapes via Kubernetes services; PodMonitor scrapes pods directly, useful for headless services)

5. How does Prometheus Operator simplify Prometheus? (It provides CRDs (Prometheus, ServiceMonitor, etc.) to configure Prometheus declaratively, rather than editing config files)

---

**Continue to `step-02.md`**
