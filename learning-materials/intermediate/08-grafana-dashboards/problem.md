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

## The Problem

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

## Getting Started

```bash
# Grafana comes with kube-prometheus-stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Port-forward to access
kubectl port-forward svc/kube-prometheus-grafana 3000:80 -n monitoring

# Default credentials: admin / prom-operator
```

---

**Start with `step-01.md`**
