# Step 1: SLOs, SLIs, and Alerting

---

## SLIs and SLOs

**SLI (Service Level Indicator)**: A measured metric of service behavior
**SLO (Service Level Objective)**: A target value for that metric

### Common SLIs

| SLI | Description | Typical SLO |
|-----|-------------|------------|
| **Availability** | % of successful requests | 99.9% |
| **Latency** | Response time | P95 < 200ms |
| **Error Rate** | % of failed requests | < 0.1% |
| **Throughput** | Requests per second | > 1000 RPS |

### SLI Examples

```promql
# Availability
rate(http_requests_total{status!~"5.."}[5m]) / rate(http_requests_total[5m])

# Latency (P95)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error Rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

## Alerting with Prometheus

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myapp-alerts
  namespace: monitoring
spec:
  groups:
  - name: myapp.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_errors_total[5m]) > 0.01
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value | humanizePercentage }}"
    
    - alert: SLOMiss
      expr: |
        (
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))
        ) > 0.001
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "SLO breach detected"
```

## Alert Priority

| Severity | Response Time | Examples |
|----------|--------------|----------|
| **P1/Critical** | Immediate | Service down, SLO breach |
| **P2/Warning** | Within hour | High latency, error spike |
| **P3/Info** | Within day | Below capacity thresholds |

---

## Quick Check

1. What's the difference between SLI and SLO? (SLI is a measured metric of service behavior like availability or latency; SLO is a specific target value for that metric like 99.9% availability)

2. Why set alert thresholds below SLO limits? (To create a buffer to take action before the SLO is actually breached, giving time to respond and fix issues)

3. What's the `for` field in Prometheus alerts? (The duration the condition must be true before firing, preventing alerts for transient blips)

4. What's P95 latency? (The 95th percentile - 95% of requests complete faster than this value, useful for identifying slow outliers)

5. What are the three alert severities? (P1/Critical - immediate response; P2/Warning - within hour; P3/Info - within day)

---

**Continue to `step-02.md`**
