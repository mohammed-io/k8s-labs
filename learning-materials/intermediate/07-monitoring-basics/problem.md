---
name: "Monitoring Basics with Prometheus"
category: "intermediate"
difficulty: "intermediate"
time: "50 minutes"
concepts: ["prometheus", "metrics", "servicemonitor", "recording-rules"]
tools: ["kubectl", "helm", "prometheus"]
---

# Monitoring Basics with Prometheus

Learn to monitor Kubernetes applications with Prometheus.

## Scenario

You need visibility into:
- Application performance metrics
- Resource utilization trends
- Service health status
- Anomalies and failures

Prometheus + ServiceMonitor + Grafana provide the solution.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  App Pods   │────▶│ ServiceMonitor│────▶│ Prometheus  │
│ (exposes    │     │ (CRD for     │     │ (Scrapes &  │
│  /metrics)  │     │  discovery)  │     │  stores)    │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │   Grafana   │
                                          │ (Visualizes)│
                                          └─────────────┘
```

## Requirements

1. **Prometheus Operator**: Install via Helm
2. **ServiceMonitor**: Create for app discovery
3. **Recording Rules**: Pre-compute frequently used queries
4. **Alerting Rules**: Set up alerts for conditions

## Constraints

- Use Prometheus Operator CRDs (`ServiceMonitor`, `PrometheusRule`) for configuration
- Keep metric names/labels consistent across examples
- Ensure monitoring resources are created in expected namespaces

## Prerequisites

- ✅ Kubernetes basics
- ✅ Services and networking
- Helm installed

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **ServiceMonitor** | Enables declarative scrape target discovery |
| **Recording Rules** | Reduces query cost and dashboard latency |
| **Alerting Rules** | Detects failures and performance regressions early |
| **PromQL** | Enables useful operational insights from raw metrics |

## Getting Started

```bash
# Add prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

## Verification

```bash
kubectl get servicemonitor -n monitoring
kubectl get prometheusrule -n monitoring
kubectl get pods -n monitoring
```

---

**Start with `step-01.md`**
