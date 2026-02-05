# SLO & SLI Guide

**Service Level Objectives and Service Level Indicators - A complete guide.**

---

## Table of Contents

1. [Core Concepts](#1-core-concepts)
2. [Defining SLIs](#2-defining-slis)
3. [Setting SLOs](#3-setting-slos)
4. [Error Budgets](#4-error-budgets)
5. [Implementing SLOs in Prometheus](#5-implementing-slos-in-prometheus)
6. [SLO-Based Alerting](#6-slo-based-alerting)

---

## 1. Core Concepts

```
                           Commitment
                        to your users
                              │
                              ▼
                    ┌───────────────────┐
                    │       SLO         │
                    │  Service Level    │
                    │    Objective      │
                    │                   │
                    │  "99.9% of API    │
                    │   requests will   │
                    │   succeed within   │
                    │   500ms"          │
                    └─────────┬─────────┘
                              │
                              │ Measured by
                              ▼
                    ┌───────────────────┐
                    │       SLI         │
                    │  Service Level    │
                    │    Indicator      │
                    │                   │
                    │  success_rate =   │
                    │  successful /     │
                    │  total_requests   │
                    │                   │
                    │  p95_latency =    │
                    │  95th percentile  │
                    │  request_time     │
                    └───────────────────┘
```

### Definitions

| Term | Definition | Example |
|------|------------|--------|
| **SLA** | Contract with customers (legal) | "99.9% uptime or credit" |
| **SLO** | Internal target for SLA | "99.95% success rate" |
| **SLI** | Metric measuring SLO | "successful / total requests" |
| **Error Budget** | Allowable failures | "0.1% = 43min/month" |

### Relationship

```
                      SLA (Promise to customers)
                              │
                      Must be better than
                              │
                              ▼
                      SLO (Internal target)
                              │
                      Buffer for incidents
                              │
                              ▼
                   Actual Performance (SLI measurement)
```

---

## 2. Defining SLIs

### 2.1 SLI Types

```
SLI Categories:
│
├─ 1. Availability-Based
│   ├─ Uptime percentage
│   ├─ Success rate
│   └─ Reachability
│
├─ 2. Latency-Based
│   ├─ Average latency
│   ├─ Percentile latency (p50, p95, p99)
│   └─ Threshold-based (requests under X ms)
│
├─ 3. Quality-Based
│   ├─ Error rate
│   ├─ Data freshness
│   └─ Correctness
│
└─ 4. Business-Based
    ├─ Conversion rate
    ├─ Search success rate
    └─ Checkout completion rate
```

### 2.2 Selecting SLIs

**Criteria for good SLIs:**

1. **User-facing** - Does it affect user experience?
2. **Measurable** - Can we actually measure it?
3. **Actionable** - Can we improve it?
4. **Understandable** - Can stakeholders understand it?

**Examples:**

| Service | Good SLIs | Bad SLIs |
|---------|-----------|----------|
| **API** | Success rate, p95 latency | Server uptime, CPU usage |
| **Database** | Query success rate, p99 query time | Replication lag (unless it affects users) |
| **Web App** | Page load time, click-through rate | Time to First Byte (too technical) |
| **CDN** | Cache hit rate, response time | Origin server health |

### 2.3 SLI Formulas

```promql
# Success Rate SLI
success_rate = sum(rate(requests_total{status!~"5.."}[5m])) /
               sum(rate(requests_total[5m]))

# Latency SLI (percentage of requests under threshold)
latency_sli = sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m])) /
              sum(rate(http_request_duration_seconds_count[5m]))

# Error Rate SLI
error_rate = sum(rate(requests_total{status=~"5.."}[5m])) /
             sum(rate(requests_total[5m]))

# Availability SLI (uptime)
availability = up{job="myapp"}
```

---

## 3. Setting SLOs

### 3.1 Common SLO Targets

| Service Type | Typical SLO | Rationale |
|--------------|-------------|-----------|
| **Critical payment API** | 99.99%+ (4 9's) | Direct revenue impact |
| **User-facing API** | 99.9% (3 9's) | Good user experience |
| **Internal API** | 99% (2 9's) | Developer productivity |
| **Data pipeline** | 95% | Batch processing, retries OK |
| **Dev/test environment** | 90% | Non-production |

### 3.2 SLO Setting Process

```
Step 1: Measure Current Performance
│
├─ Collect data for 2-4 weeks
├─ Calculate baseline SLIs
└─ Understand variability
│
Step 2: Consider User Expectations
│
├─ What do users tolerate?
├─ What do competitors offer?
└─ What's technically feasible?
│
Step 3: Set Initial SLO
│
├─ Start at or slightly below current performance
├─ Leave room for improvement
└─ Document assumptions
│
Step 4: Iterate Quarterly
│
├─ Review performance
├─ Adjust SLO if needed
└─ Communicate changes
```

### 3.3 SLO Examples

```
Example 1: Public API
┌─────────────────────────────────────────────────┐
│ SLO: 99.9% of successful API requests within    │
│      500ms, 24/7                                │
│                                                  │
│ Breakdown:                                       │
│ ├─ SLI 1: Success rate ≥ 99.9%                  │
│ ├─ SLI 2: p95 latency ≤ 500ms                   │
│ └─ SLI 3: Availability ≥ 99.9%                  │
│                                                  │
│ Measurement: 30-day rolling window               │
│ Error Budget: 43.2 minutes/month                │
└─────────────────────────────────────────────────┘

Example 2: Data Pipeline
┌─────────────────────────────────────────────────┐
│ SLO: 95% of daily data jobs complete within     │
│      their SLA (4 hours after data arrives)     │
│                                                  │
│ Breakdown:                                       │
│ ├─ SLI 1: Job success rate ≥ 99%                │
│ ├─ SLI 2: Data freshness ≤ 4 hours              │
│ └─ SLI 3: Data accuracy ≥ 99.9%                 │
│                                                  │
│ Measurement: Daily rolling window                │
│ Error Budget: 1 failed job per day              │
└─────────────────────────────────────────────────┘

Example 3: E-commerce Checkout
┌─────────────────────────────────────────────────┐
│ SLO: 99.5% of checkout attempts succeed         │
│                                                  │
│ Breakdown:                                       │
│ ├─ SLI 1: Checkout success rate ≥ 99.5%         │
│ ├─ SLI 2: Checkout latency p95 ≤ 2 seconds      │
│ └─ SLI 3: Payment API availability ≥ 99.9%      │
│                                                  │
│ Measurement: 7-day rolling window               │
│ Error Budget: 21.6 minutes/week                 │
└─────────────────────────────────────────────────┘
```

---

## 4. Error Budgets

### 4.1 Calculating Error Budgets

```
Error Budget = 100% - SLO

Example:
┌─────────────────────────────────────────────────┐
│ SLO: 99.9%                                      │
│ Error Budget: 0.1%                              │
│                                                  │
│ Time Period Calculations:                        │
│ ├─ Per day:   0.1% of 24h = 86.4 seconds        │
│ ├─ Per week:  0.1% of 7d  = 10.1 minutes        │
│ ├─ Per month: 0.1% of 30d = 43.2 minutes        │
│ └─ Per year:  0.1% of 365d = 8.76 hours         │
└─────────────────────────────────────────────────┘
```

### 4.2 Burn Rate

**Burn rate** = How fast you're consuming your error budget

```
Burn Rate Calculations:
┌─────────────────────────────────────────────────┐
│ Current error rate: 0.5%                        │
│ Error budget: 0.1%                              │
│                                                  │
│ Burn Rate = 0.5% / 0.1% = 5x                    │
│                                                  │
│ At 5x burn rate:                                │
│ ├─ Budget exhausted in: 30 days / 5 = 6 days   │
│ └─ Remaining budget time: 43.2 min / 5 ≈ 8.6min │
└─────────────────────────────────────────────────┘
```

### 4.3 Burn Rate Alerting

```
Alert Levels:
┌────────────────────────────────────────────────────┐
│ Burn Rate │ Action                  │ Example      │
├───────────┼─────────────────────────┼──────────────┤
│ 1x        │ Normal                  │ On track     │
│ 2x        │ Warning                 │ Monitor      │
│ 5x        │ Page on-call            │ Investigate  │
│ 10x+      │ Page + declare incident │ War room    │
└────────────────────────────────────────────────────┘
```

---

## 5. Implementing SLOs in Prometheus

### 5.1 Recording Rules

```yaml
# recording_rules.yaml
groups:
- name: slo_rules
  interval: 30s
  rules:
  # Success rate SLI
  - record: api:http_requests:success_rate_5m
    expr: |
      sum(rate(http_requests_total{job="api",status!~"5.."}[5m])) /
      sum(rate(http_requests_total{job="api"}[5m]))

  # Latency SLI (fast requests)
  - record: api:http_requests:fast_rate_5m
    expr: |
      sum(rate(http_request_duration_seconds_bucket{job="api",le="0.5"}[5m])) /
      sum(rate(http_request_duration_seconds_count{job="api"}[5m]))

  # SLO compliance (30-day window would need Thanos/VictoriaMetrics)
  - record: api:slo:success_rate_30d
    expr: |
      avg_over_time(api:http_requests:success_rate_5m[30d])
```

### 5.2 SLO Dashboard Queries

```promql
# Current success rate
api:http_requests:success_rate_5m

# Error budget remaining
(api:slo:success_rate_30d - 0.99) / (1 - 0.99) * 100

# Requests per second
sum(rate(http_requests_total{job="api"}[5m]))

# p95 latency
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket{job="api"}[5m])) by (le)
)

# Time to error budget exhaustion
# (if burning at current rate)
(
  (1 - 0.99) * 30 * 24 * 3600  # Total error budget in seconds
) /
(
  (1 - api:http_requests:success_rate_5m) * sum(rate(http_requests_total{job="api"}[5m])) * 30 * 24 * 3600
)
```

---

## 6. SLO-Based Alerting

### 6.1 Multi-Window Alerting

```
The Problem:
┌─────────────────────────────────────────────────┐
│ "Alert when error rate > 1%"                    │
│                                                  │
│ This creates:                                    │
│ ├─ Noise during brief spikes                     │
│ ├─ Missed sustained low-level degradation       │
│ └─ No SLO context                               │
└─────────────────────────────────────────────────┘

The Solution: Multi-Window, Multi-Burn-Rate
┌─────────────────────────────────────────────────┐
│ Alert when:                                     │
│   error rate > 1% for 1 hour  OR                │
│   error rate > 0.5% for 6 hours                 │
│                                                  │
│ This catches:                                    │
│ ├─ Significant short-term problems              │
│ ├─ Sustained minor problems                     │
│ └─ Is tied to SLO impact                       │
└─────────────────────────────────────────────────┘
```

### 6.2 Alert Rules

```yaml
groups:
- name: slo_alerts
  rules:
  # 5% error rate = 50x burn rate (very bad!)
  - alert: ServiceDegradedCritical
    expr: |
      (1 - api:http_requests:success_rate_5m) > 0.05
    for: 2m
    labels:
      severity: critical
      slo: "api-success-rate"
    annotations:
      summary: "API success rate below 95%"
      description: "{{ $value | humanizePercentage }} success rate (target: 99%)"
      runbook: "https://runbooks.example.com/api-errors"

  # 1% error rate = 10x burn rate
  - alert: ServiceDegradedWarning
    expr: |
      (1 - api:http_requests:success_rate_5m) > 0.01
    for: 10m
    labels:
      severity: warning
      slo: "api-success-rate"
    annotations:
      summary: "API success rate below 99%"

  # 0.5% error rate = 5x burn rate, sustained
  - alert: ServiceDegradedSustained
    expr: |
      (1 - api:http_requests:success_rate_5m) > 0.005
    for: 1h
    labels:
      severity: warning
      slo: "api-success-rate"
    annotations:
      summary: "Sustained API degradation"
      burn_rate: "5x"

  # Latency SLO breach
  - alert: LatencySLOBreached
    expr: |
      (
        histogram_quantile(0.95,
          sum(rate(http_request_duration_seconds_bucket{job="api"}[5m])) by (le)
        )
      ) > 0.5
    for: 10m
    labels:
      severity: warning
      slo: "api-latency"
    annotations:
      summary: "API p95 latency above 500ms"
```

---

## SLO Implementation Checklist

### Planning
- [ ] Identify user journeys
- [ ] Select SLIs for each journey
- [ ] Measure current performance (2-4 weeks)
- [ ] Set initial SLO targets
- [ ] Calculate error budgets

### Technical
- [ ] Create recording rules
- [ ] Build SLO dashboards
- [ ] Configure SLO-based alerts
- [ ] Set up long-term storage (for 30d+ windows)

### Process
- [ ] Document SLOs
- [ ] Create runbooks for alerts
- [ ] Define incident response process
- [ ] Schedule quarterly SLO reviews

### Communication
- [ ] Share SLOs with stakeholders
- [ ] Publish status dashboard
- [ ] Train on-call team
- [ ] Escalation procedures defined

---

## Common Mistakes

| Mistake | Why It's Bad | Fix |
|---------|--------------|-----|
| Setting SLO based on current perf | No incentive to improve | Set aspirational but achievable |
| Too many SLOs | Loss of focus | 1-3 SLOs per service |
| SLO too loose | Doesn't drive quality | Tighten over time |
| SLO too tight | Constant breaches | Start reasonable |
| Not measuring before setting | Unknown baseline | Measure first |
| Ignoring error budget | No risk management | Track and plan usage |
| Alerting on raw metrics | Noise | Alert on SLO breaches |
| Only measuring uptime | Incomplete picture | Measure user experience |

---

**Remember:** SLOs are a conversation tool, not just a technical one. They align engineering, product, and business around what "good" means.
