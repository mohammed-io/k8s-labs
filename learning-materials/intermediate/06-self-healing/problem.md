---
name: "Self-Healing & Auto-Scaling"
category: "intermediate"
difficulty: "intermediate"
time: "45 minutes"
concepts: ["hpa", "vpa", "health-probes", "pod-disruption-budget"]
tools: ["kubectl", "minikube"]
---

# Self-Healing & Auto-Scaling

Learn how Kubernetes automatically recovers from failures and scales applications.

## The Problem

Applications encounter failures at multiple levels:
- Containers crash due to bugs
- Pods run out of memory
- Traffic spikes overwhelm the system
- Nodes fail entirely

You need to configure Kubernetes to automatically detect and recover from these failures.

## Architecture

```
Self-Healing Hierarchy:

Level 1: Application → Retry logic, circuit breakers
Level 2: Container → Restart policy, liveness/readiness probes
Level 3: Pod → ReplicaSet maintains desired count
Level 4: Node → Node auto-repair, pod eviction
Level 5: Service → HPA, VPA, Cluster Autoscaler
```

## Requirements

1. **Health Probes**: Configure liveness, readiness, and startup probes
2. **HPA**: Set up horizontal pod autoscaling based on CPU/memory
3. **VPA**: Understand vertical pod autoscaling for resource optimization
4. **PodDisruptionBudget**: Protect application availability during maintenance

## Prerequisites

- ✅ Scenarios 01-05: Kubernetes basics, networking, storage, Helm
- Metrics server installed for HPA
- kubectl installed

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **Health Probes** | Enable Kubernetes to detect and restart unhealthy pods |
| **HPA** | Automatically scale based on load |
| **VPA** | Optimize resource allocation |
| **PDB** | Maintain availability during disruptions |

## Getting Started

```bash
# Install metrics server (required for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify
kubectl get apiservice v1beta1.metrics.k8s.io
```

---

**Start with `step-01.md`**
