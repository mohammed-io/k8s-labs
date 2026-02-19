---
name: "Kubernetes Networking"
category: "basics"
difficulty: "intermediate"
time: "45 minutes"
concepts: ["service", "ingress", "network-policy", "dns"]
tools: ["kubectl", "minikube"]
---

# Kubernetes Networking

Learn how Kubernetes networking works and how to expose your applications.

## Scenario

You have multiple microservices that need to communicate:
- **Frontend** (web app) - needs to reach the API
- **API** - needs to reach the database and cache
- **Admin panel** - should only be accessible from VPN

Your tasks will set up proper networking for these services.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                       Internet                           │
│                          │                               │
│                          ▼                               │
│                   ┌──────────────┐                       │
│                   │    Ingress   │                       │
│                   │  Controller  │                       │
│                   └──────┬───────┘                       │
│                          │                               │
│         ┌────────────────┼────────────────┐              │
│         ▼                ▼                ▼              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐          │
│  │  Service │    │  Service │    │  Service │          │
│  │   /web   │    │   /api   │    │  /admin  │          │
│  └──────────┘    └──────────┘    └──────────┘          │
└──────────────────────────────────────────────────────────┘
```

## Requirements

1. **Services**: Create ClusterIP, NodePort, and LoadBalancer services
2. **Service Discovery**: Use DNS to find services
3. **Ingress**: Set up HTTP routing based on path and hostname
4. **Network Policies**: Control traffic flow between pods

## Constraints

- Use the correct Service type for each use case
- Ingress requires an Ingress controller to be installed first
- Network policies require a CNI that supports them (Calico, Cilium)

## Prerequisites

- ✅ Scenario 01: Kubernetes Basics (Pods, Deployments)
- ✅ Understanding of IP addresses and ports
- kubectl installed
- Kubernetes cluster running (minikube, kind, or k3d)

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **ClusterIP** | Default service type for internal communication |
| **NodePort** | Expose service externally on node IP |
| **LoadBalancer** | Cloud load balancer integration |
| **Ingress** | HTTP/HTTPS routing for multiple services |
| **NetworkPolicy** | Security through traffic control |

## Getting Started

```bash
# Verify your cluster is running
kubectl cluster-info

# Start minikube with ingress enabled (if using minikube)
minikube start --cpus=4 --memory=8192
minikube addons enable ingress
```

## Verification

After completing this scenario, you should be able to:
- Create and use different Service types
- Access services via DNS
- Set up Ingress for HTTP routing
- Control traffic with Network Policies

---

**Start with `step-01.md`**
