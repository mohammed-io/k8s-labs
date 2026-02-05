# Observability Strategy

**What to observe, why to observe it, and what NOT to observe.**

---

## Table of Contents

1. [The Three Pillars](#1-the-three-pillars)
2. [What to Observe (and Why)](#2-what-to-observe-and-why)
3. [What NOT to Observe (and Why)](#3-what-not-to-observe-and-why)
4. [Observability Maturity Model](#4-observability-maturity-model)
5. [Building Your Strategy](#5-building-your-strategy)

---

## 1. The Three Pillars

```
                    OBSERVABILITY
                         │
    ┌────────────────────┼────────────────────┐
    │                    │                    │
    ▼                    ▼                    ▼
┌─────────┐        ┌─────────┐        ┌─────────┐
│ Metrics │        │  Logs   │        │ Traces  │
│         │        │         │        │         │
│ Numbers │        │ Records │        │ Journeys│
│ over    │        │ with    │        │ across  │
│ time    │        │ context │        │ services│
│         │        │         │        │         │
│ Best    │        │ Best    │        │ Best    │
│ For:    │        │ For:    │        │ For:    │
│ - Trends│        │ - Debug │        │ - Optims │
│ - Alert │        │ - Audit │        │ - Dist. │
│ - Dash  │        │ - Root  │        │ systems │
└─────────┘        └─────────┘        └─────────┘
```

### When to Use Each Pillar

| Question | Use | Example |
|----------|-----|---------|
| "Is something wrong?" | **Metrics** | CPU at 90%, error rate 5% |
| "Why is it wrong?" | **Logs** | "NullPointerException at UserService.java:42" |
| "Where is the slowdown?" | **Traces** | "DB query took 500ms in checkout flow" |

---

## 2. What to Observe (and Why)

### 2.1 The Four Golden Signals

**Source:** Google SRE Book

```
┌──────────────────────────────────────────────────────────────┐
│                     The Four Golden Signals                  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. LATENCY      ─────►  How long does it take?             │
│  2. TRAFFIC      ─────►  How much demand?                   │
│  3. ERRORS       ─────►  How many failures?                 │
│  4. SATURATION   ─────►  How full is the system?             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### Signal 1: Latency

**What:** Time to service requests

**Why:** User experience depends on it

**How to measure:**
```promql
# Request duration (p95 is what users experience)
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[5m])
)

# Break down by endpoint
histogram_quantile(0.95,
  sum by (le, endpoint) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

**What NOT to do:**
- Don't use average (hides tail latency)
- Don't ignore p99 (power users matter)
- Don't measure only successful requests (failures are fast = misleading)

#### Signal 2: Traffic

**What:** Demand on the system

**Why:** Capacity planning, scaling decisions

**How to measure:**
```promql
# Requests per second
sum(rate(http_requests_total[5m]))

# By endpoint
sum by (endpoint) (rate(http_requests_total[5m]))

# By status code
sum by (status) (rate(http_requests_total[5m]))
```

**What NOT to do:**
- Don't count internal health checks
- Don't mix HTTP and TCP traffic
- Don't forget failed requests (still traffic!)

#### Signal 3: Errors

**What:** Failed requests

**Why:** Direct impact on users

**How to measure:**
```promql
# Error rate (5xx)
sum(rate(http_requests_total{status=~"5.."}[5m])) /
sum(rate(http_requests_total[5m]))

# By endpoint
sum by (endpoint) (
  rate(http_requests_total{status=~"5.."}[5m])
)

# Business logic errors
sum(rate(app_errors_total{type="validation"}[5m]))
```

**What NOT to do:**
- Don't alert on every error (transient errors happen)
- Don't ignore 4xx codes (client errors matter too)
- Don't forget non-HTTP errors

#### Signal 4: Saturation

**What:** How full is the system

**Why:** Predicts when things will break

**How to measure:**
```promql
# CPU saturation
rate(container_cpu_usage_seconds_total[5m]) /
container_cpu_limit_seconds_total

# Memory saturation
container_memory_working_set_bytes /
container_spec_memory_limit_bytes

# Disk saturation
rate(node_disk_io_time_seconds_total[5m])

# Connection pool saturation
db_connections_active / db_connections_max
```

**What NOT to do:**
- Don't monitor alone (context matters)
- Don't ignore soft saturation (connection pools, queues)
- Don't forget downstream dependencies

---

### 2.2 The RED Method (for Services)

**Source:** Tom Wilkie (creator of Loki)

```
R ──► Rate      (Requests per second)
E ──► Errors    (Failed requests)
D ──► Duration  (Request latency)
```

**Implementation:**
```promql
# Rate
sum(rate(http_requests_total{job="myapp"}[5m]))

# Errors
sum(rate(http_requests_total{job="myapp",status=~"5.."}[5m])) /
sum(rate(http_requests_total{job="myapp"}[5m]))

# Duration (p95)
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket{job="myapp"}[5m])
)
```

---

### 2.3 The USE Method (for Resources)

**Source:** Brendan Gregg

```
U ──► Utilization  (Average resource usage)
S ──► Saturation   (How full is the resource)
E ──► Errors       (Errors accessing the resource)
```

**Per Resource:**

| Resource | Utilization | Saturation | Errors |
|----------|-------------|------------|--------|
| **CPU** | `cpu_usage_percent` | `run_queue_length` | `cpu_cfs_throttled` |
| **Memory** | `memory_usage_percent` | `swap_used` | `oom_kills` |
| **Disk** | `disk_usage_percent` | `ioutil` | `disk_errors` |
| **Network** | `bandwidth_usage_percent` | `conntrack_used` | `tcp_retransmits` |

---

## 3. What NOT to Observe (and Why)

### 3.1 The "Monitor Everything" Trap

```
❌ What happens when you monitor everything:

┌────────────────────────────────────────┐
│  Metrics collected: 50,000             │
│  Cost: $$$$$                           │
│  Query speed: 🐌                       │
│  Alert quality: 📉                     │
│  Team happiness: 😞                    │
└────────────────────────────────────────┘
```

**Why it's bad:**
1. **Cost** - Storage and computation scale with metrics
2. **Performance** - Slow queries when you need answers fast
3. **Noise** - Can't see signal in the noise
4. **Maintenance** - Someone has to manage all this

**Better approach:**
```promql
# Start with 5-10 key metrics per service
rate(http_requests_total[5m])
rate(http_requests_total{status="5xx"}[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
cpu_usage_percent
memory_usage_percent

# Add more ONLY when you have a specific question
```

---

### 3.2 Metrics That Mislead

**❌ Don't monitor:**

1. **Raw CPU/Memory without context**
   ```promql
   # Why is this bad?
   cpu_usage_percent > 80
   # 80% might be:
   # - Normal for a worker service
   # - A problem for a critical API
   # - Too low for an expensive batch job
   ```

2. **Queue length alone**
   ```promql
   # Why is this bad?
   queue_length > 1000
   # Context needed:
   # - How fast is it processing?
   # - Is it growing or shrinking?
   # - What's the processing time per item?
   ```

3. **Dashboard without SLO**
   ```
   # Why is this bad?
   "What's our latency?"
   # Response: "50ms"
   # But... is that good? What's our target?
   # Without SLO: 50ms means nothing
   # With SLO: "50ms vs 100ms target = we're good!"
   ```

4. **Uptime percentage alone**
   ```
   # Why is this bad?
   "We're 99% up!"
   # But... 1% downtime = 7.2 hours/month
   # Is that acceptable? What did users lose?
   ```

---

### 3.3 Alerts That Don't Help

**❌ Don't alert on:**

1. **Symptoms, not causes**
   ```yaml
   # Bad
   - alert: HighLatency
     expr: latency > 1s
     # "What do I do?"

   # Good
   - alert: DatabaseConnectionPoolExhausted
     expr: db_pool_active / db_pool_max > 0.9
     annotations:
       action: "Check for connection leaks, consider increasing pool size"
   ```

2. **Transient blips**
   ```yaml
   # Bad
   - alert: ErrorSpike
     expr: error_rate > 0
     # Alerts on single errors

   # Good
   - alert: HighErrorRate
     expr: error_rate > 0.05
     for: 5m  # Sustained for 5 minutes
   ```

3. **Things you can't fix**
   ```yaml
   # Bad
   - alert: CloudProviderRegionalOutage
     # If AWS us-east-1 is down, we know.
     # Alerting doesn't help.

   # Good
   - alert: OurServiceFailingOver
     expr: failover_triggered > 0
     # Something we can respond to
   ```

---

## 4. Observability Maturity Model

```
Level 1: Basic
├─ Uptime monitoring
├─ Basic metrics (CPU, memory)
└─ Error logs
```

```
Level 2: Structured
├─ RED Method metrics
├─ Structured logging (JSON)
├─ Basic dashboards
└─ On-call rotation
```

```
Level 3: SLO-Driven
├─ Defined SLOs
├─ Error budgets
├─ SLO-based dashboards
└─ Runbooks for all alerts
```

```
Level 4: Proactive
├─ Synthetic monitoring
├─ Load testing
├─ Chaos engineering
└─ Predictive alerting
```

```
Level 5: Optimized
├─ Automated remediation
├─ ML anomaly detection
├─ Cost optimization
└─ Continuous improvement
```

**Where are you?**

| Maturity | Questions You Can Answer |
|----------|-------------------------|
| **1** | Is it up? |
| **2** | Is it working? What broke? |
| **3** | Are we meeting our commitments? |
| **4** | Will it break under load? |
| **5** | How can we make it better? |

---

## 5. Building Your Strategy

### Step 1: Define What Matters

```
User Journey: "As a user, I want to purchase items"
                │
                ▼
        Critical Path Identified
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
 Browse → Add to Cart → Checkout
    │           │           │
    └───────────┴───────────┘
                │
                ▼
    What to Observe:
    ├─ Browse latency (p95 < 200ms)
    ├─ Cart success rate (>99%)
    ├─ Checkout latency (p95 < 500ms)
    └─ Checkout success rate (>99.5%)
```

### Step 2: Define SLOs

```
Service: E-Commerce API

SLO: 99.9% of checkout requests succeed within 500ms

Breakdown:
├─ Success Rate SLI: requests_succeeded / requests_total
├─ Latency SLI: histogram_quantile(0.95, request_duration)
├─ Target: 99.9% success OR <500ms p95
└─ Error Budget: 0.1% = 43.2 minutes/month
```

### Step 3: Define What to Observe

```promql
# Only what's needed for the SLO
# Success Rate
sum(rate(http_requests_total{endpoint="/checkout",status!~"5.."}[5m])) /
sum(rate(http_requests_total{endpoint="/checkout"}[5m]))

# Latency
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket{endpoint="/checkout"}[5m])
)
```

### Step 4: Define What NOT to Observe

```
Skip for now:
├─ Individual endpoint latency (only need aggregate)
├─ Per-customer metrics (too high cardinality)
├─ Internal health checks (noise)
├─ Infra metrics unless they explain user impact
└─ Nice-to-have metrics (can add later)
```

### Step 5: Build Dashboards

```
┌────────────────────────────────────────────────┐
│         E-Commerce API Dashboard               │
├────────────────────────────────────────────────┤
│                                                │
│  SLO Status: ████████░░ 99.87% (Target: 99.9%) │ ← Signal
│  Error Budget: 3.2 days remaining              │
│                                                │
│  Checkout Rate  ┌──────────────────────────┐   │
│  ──────────────►│ Graph                   │   │
│                └──────────────────────────┘   │
│                                                │
│  Checkout p95  ┌──────────────────────────┐   │
│  ─────────────►│ Graph                   │   │
│                └──────────────────────────┘   │
│                                                │
│  Error Rate    ┌──────────────────────────┐   │
│  ─────────────►│ Graph                   │   │
│                └──────────────────────────┘   │
│                                                │
└────────────────────────────────────────────────┘
```

### Step 6: Define Alerts

```yaml
# Alert when SLO is at risk
- alert: CheckoutSLOAtRisk
  expr: |
    (
      1 - (
        sum(rate(http_requests_total{endpoint="/checkout",status!~"5.."}[5m])) /
        sum(rate(http_requests_total{endpoint="/checkout"}[5m]))
      )
    ) < 0.995
  for: 10m
  annotations:
    severity: critical
    summary: "Checkout SLO at risk"
    runbook: "https://runbooks.example.com/checkout-slo"
```

---

## Observability Decision Tree

```
                    Should I observe this?
                              │
               ┌──────────────┴──────────────┐
               │                             │
          Does it answer                    NO
          a user-facing         ┌─────────────┴──────────────┐
          question?            │                            │
               │             YES                            Skip
               │               │                          (for now)
              YES             │
               │               │
               │          Can I take action
               │          based on this?
               │               │
               │      ┌────────┴────────┐
               │      │                 │
               │     YES               NO
               │      │                 │
               ▼      ▼                 ▼
          OBSERVE  OBSERVE         Skip (for now)
           & ALERT   (maybe)
```

---

## Key Takeaways

| Principle | Action |
|-----------|--------|
| **Start with user experience** | Define user journeys first |
| **Measure what matters** | Only what affects users |
| **Set SLOs before metrics** | Know what "good" looks like |
| **Alert on causes** | Not symptoms |
| **Use RED for services** | Rate, Errors, Duration |
| **Use USE for resources** | Utilization, Saturation, Errors |
| **Avoid metric explosion** | High cardinality = expensive |
| **Cost-benefit analysis** | Is this worth the storage cost? |

---

**Next:** See `docs/SLO_SLI_GUIDE.md` for defining service level objectives.
