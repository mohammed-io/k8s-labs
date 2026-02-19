---
name: "Grafana Dashboards"
category: "intermediate"
difficulty: "intermediate"
time: "40 minutes"
concepts: ["grafana", "dashboard", "panels", "variables"]
tools: ["kubectl", "helm", "grafana"]
---

# Grafana Dashboards

Learn to create and manage Grafana dashboards for Kubernetes monitoring.

## Scenario

You have Prometheus collecting metrics, but you need:
- Visual dashboards for monitoring
- Custom panels for your applications
- Variables for dashboard interactivity
- Dashboard versioning

## Architecture

```
┌──────────────────┐     ┌──────────────────┐
│   Grafana        │────▶│ Prometheus       │
│   Dashboards     │     │   (Data Source)  │
│                  │     └──────────────────┘
│  • Panels        │
│  • Variables     │
│  • Annotations   │
│  • Alerts        │
└──────────────────┘
```

## Requirements

1. **Grafana**: Install and configure
2. **Dashboards**: Create ConfigMaps for dashboard definitions
3. **Variables**: Add dynamic filters
4. **Provisioning**: Set up dashboard-as-code

## Constraints

- Dashboard definitions must be version-controlled (ConfigMap-based)
- Include variable-driven filtering for namespace/pod
- Keep queries compatible with Prometheus metric labels

## Prerequisites

- Prometheus and Grafana installed (for example via kube-prometheus-stack)
- Basic PromQL familiarity
- kubectl access to the monitoring namespace

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **Dashboard Provisioning** | Allows repeatable, code-reviewed dashboards |
| **Variables** | Enables reusable dashboards across workloads |
| **Panel Selection** | Balances overview and deep-dive observability |
| **Query Design** | Prevents misleading or expensive visualizations |

## Getting Started

```bash
# Grafana comes with kube-prometheus-stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Port-forward to access
kubectl port-forward svc/kube-prometheus-grafana 3000:80 -n monitoring

# Default credentials: admin / prom-operator
```

## Verification

```bash
kubectl get configmap myapp-dashboard -n monitoring
kubectl get configmap myapp-dashboard -n monitoring -o yaml
```

---

**Start with `step-01.md`**
