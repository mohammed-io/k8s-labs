---
name: "Production-Ready Kubernetes"
category: "advanced"
difficulty: "advanced"
time: "60 minutes"
concepts: ["slo", "sli", "alerting", "disaster-recovery", "security"]
tools: ["kubectl", "helm", "prometheus", "grafana"]
---

# Production-Ready Kubernetes

Learn to build production-grade Kubernetes applications with reliability best practices.

## Scenario

Production requires:
- Clear reliability targets (SLOs)
- Effective alerting
- Security hardening
- Disaster recovery plans
- Multi-environment strategy

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Production Readiness                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│
│  │   SLO    │  │ Alerting │  │ Security │  │  DR/BCP ││
│  │  & SLI   │  │   Rules  │  │   Hardening  │    │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘│
│                                                          │
│  Supported by:                                          │
│  • Observability (metrics, logs, traces)                  │
│  • Resource quotas & limits                              │
│  • Network policies                                      │
│  • Backup strategies                                     │
└─────────────────────────────────────────────────────────┘
```

## Requirements

1. **SLOs/SLIs**: Define reliability targets
2. **Alerting**: Configure Prometheus alerts
3. **Security**: Network policies, RBAC, secrets management
4. **Backup**: etcd and application backup strategies

## Constraints

- Use namespace-scoped controls first (ResourceQuota, LimitRange, NetworkPolicy)
- Keep examples declarative and reproducible with manifest files
- Prefer non-destructive cleanup that only removes lab resources

## Prerequisites

- ✅ All previous scenarios completed
- Understanding of Prometheus and Grafana

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **SLI/SLO** | Sets measurable reliability targets |
| **Alerting** | Detects incidents before SLO burn becomes critical |
| **Resource Controls** | Prevents noisy neighbors and runaway workloads |
| **NetworkPolicy** | Reduces lateral movement and attack surface |
| **Recovery Planning** | Improves resilience and operational readiness |

## Getting Started

Review your current setup and identify production gaps.

## Verification

Confirm that your namespace contains:
- A `ResourceQuota` and `LimitRange`
- A default deny `NetworkPolicy`
- A valid Alertmanager config object

Use:
```bash
kubectl get resourcequota,limitrange,networkpolicy -n production
kubectl get configmap alertmanager-config -n monitoring
```

---

**Start with `step-01.md`**
