# Kubernetes & Monitoring Learning Lab

**Hands-on learning for Kubernetes, Prometheus, Grafana, and OpenTelemetry.**

All scenarios run locally using:
- **kind** (Kubernetes in Docker) - Full K8s cluster locally
- **minikube** - Alternative local K8s
- **Helm** - Package manager for K8s
- **Prometheus** - Metrics collection
- **Grafana** - Visualization and dashboards
- **OpenTelemetry** - Observability standard

**No cloud account required.**

---

## Quick Start

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install kind
brew install kind

# Create a cluster
kind create cluster --name lab

# Verify
kubectl cluster-info
kubectl get nodes
```

---

## Project Structure

```
k8s-monitoring-lab/
├── README.md                      # This file
├── docs/                          # Comprehensive guides
│   ├── QUICK_REFERENCE.md          # ⭐ Daily commands cheat sheet
│   ├── K8S_CONCEPTS.md             # Deep dive into K8s concepts
│   ├── MONITORING_CONCEPTS.md      # Prometheus, Grafana, OTEL
│   ├── BEST_PRACTICES.md           # What to do (and not do)
│   ├── ANTI_PATTERNS.md            # Common mistakes
│   ├── OBSERVABILITY_STRATEGY.md   # What to observe and why
│   └── SLO_SLI_GUIDE.md            # Service Level Objectives
├── scenarios/                      # Hands-on exercises
│   ├── 01-k8s-basics/              # Pods, Deployments, Services
│   ├── 02-config-secrets/           # ConfigMaps, Secrets
│   ├── 03-networking/               # Ingress, Network Policies
│   ├── 04-storage/                  # PV, PVC, StatefulSets
│   ├── 05-helm-charts/              # Package management
│   ├── 06-self-healing/            # HPA, VPA, probes, circuit breakers
│   ├── 07-monitoring-basics/        # Prometheus setup
│   ├── 08-grafana-dashboards/       # Visualization
│   ├── 09-opentelemetry/            # Distributed tracing
│   └── 10-production-ready/         # Complete production setup
├── answers/                        # Reference solutions
└── scripts/                        # Utility scripts
    ├── create-cluster.sh
    ├── install-prometheus.sh
    └── install-grafana.sh
```

---

## Learning Path

| Scenario | Focus | Time | Skills |
|----------|-------|------|--------|
| **01** | K8s Basics | 45 min | Pods, Deployments, Services |
| **02** | Config & Secrets | 30 min | ConfigMaps, Secrets |
| **03** | Networking | 45 min | Ingress, Network Policies |
| **04** | Storage | 45 min | PV, PVC, StorageClasses |
| **05** | Helm Charts | 45 min | Packaging, values files |
| **06** | Self-Healing | 90 min | HPA, VPA, probes, circuit breakers |
| **07** | Monitoring Basics | 60 min | Prometheus, metrics |
| **08** | Dashboards | 45 min | Grafana, visualization |
| **09** | OpenTelemetry | 60 min | Distributed tracing |
| **10** | Production Ready | 90 min | Complete monitoring stack |

**Total Time:** ~8-10 hours of hands-on practice

---

## Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| **kubectl** | `brew install kubectl` | K8s command line |
| **kind** | `brew install kind` | Local K8s cluster |
| **Helm** | `brew install helm` | K8s package manager |
| **Docker** | `brew install --cask docker` | Container runtime |

---

## Essential Commands

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Pods
kubectl get pods -A
kubectl describe pod <name>
kubectl logs <pod>
kubectl logs -f <pod>              # Follow logs
kubectl exec -it <pod> -- sh       # Shell into pod

# Deployments
kubectl get deployments
kubectl rollout restart deployment/<name>
kubectl scale deployment/<name> --replicas=3

# Services
kubectl get services
kubectl port-forward svc/<name> 8080:80

# ConfigMaps & Secrets
kubectl get configmaps
kubectl get secrets
kubectl create secret generic my-secret --from-literal=key=value

# Apply/Delete
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl delete pod/<name>

# Troubleshooting
kubectl describe pod <name>        # Full details
kubectl logs <pod> --previous      # Previous container logs
kubectl get events                 # Cluster events
kubectl top pods                    # Resource usage
kubectl top nodes
```

---

## What You'll Learn

### Kubernetes

| Concept | Why It Matters |
|---------|----------------|
| **Pods** | Smallest deployable unit |
| **Deployments** | Declarative pod management |
| **Services** | Service discovery & load balancing |
| **ConfigMaps** | Configuration without code changes |
| **Secrets** | Secure credential management |
| **Ingress** | HTTP/HTTPS routing into cluster |
| **PV/PVC** | Persistent storage |
| **StatefulSets** | Stateful applications |
| **DaemonSets** | Cluster-wide services |
| **Namespaces** | Resource isolation |
| **Resource Limits** | CPU/memory management |
| **RBAC** | Access control |
| **Helm** | Package management |

### Monitoring & Observability

| Concept | Why It Matters |
|---------|----------------|
| **Prometheus** | Metrics collection and storage |
| **Grafana** | Visualization and dashboards |
| **Alertmanager** | Alert routing and deduplication |
| **OpenTelemetry** | Vendor-neutral telemetry |
| **Metrics** | Numerical time-series data |
| **Logs** | Discrete events with context |
| **Traces** | Request journeys across services |
| **SLO/SLI** | Service Level Objectives/Indicators |
| **RED Method** | Rate, Errors, Duration |
| **USE Method** | Utilization, Saturation, Errors |
| **Golden Signals** | Latency, Traffic, Errors, Saturation |

---

## Best Practices Overview

### DO ✅

1. **Always set resource limits** on containers
2. **Use liveness and readiness probes**
3. **Namespace隔离** - Separate environments
4. **Label everything** - For selection and organization
5. **Use ConfigMaps for configuration** - Not baked in images
6. **Secrets for sensitive data** - Never in ConfigMaps
7. **Health checks** - Always define probes
8. **Multiple replicas** - At least 2 for production
9. **Rolling updates** - Use Deployments, not bare Pods
10. **Network policies** - Default deny, allow specific

### DON'T ❌

1. **Don't use bare Pods** - Use Deployments
2. **Don't use :latest tags** - Pin versions
3. **Don't skip resource limits** - Causes noisy neighbor problems
4. **Don't expose services** - Use Ingress when possible
5. **Don't ignore security** - RBAC, network policies
6. **Don't monitor everything** - Focus on signals
7. **Don't alert on symptoms** - Alert on causes
8. **Don't forget context** - Dashboards need meaning
9. **Don't set SLOs without measuring** - Baseline first
10. **Don't ignore tail latency** - P99 matters

---

## What To Observe (Deep Knowledge)

### The Four Golden Signals

1. **Latency** - Time to service requests
2. **Traffic** - Demand on the system
3. **Errors** - Rate of failed requests
4. **Saturation** - How full is the system

### RED Method (for services)

1. **Rate** - Requests per second
2. **Errors** - Failed requests
3. **Duration** - Request latency (p50, p95, p99)

### USE Method (for resources)

1. **Utilization** - Average resource usage
2. **Saturation** - How full is the resource
3. **Errors** - Errors accessing the resource

### What NOT to Monitor (Anti-patterns)

1. CPU/Memory % alone - Without context, meaningless
2. Every possible metric - Creates noise
3. Dashboard without SLO - What does "good" look like?
4. Alerts without runbooks - Who responds and how?
5. Counting everything - Expensive and noisy

---

## Getting Started

```bash
# 1. Install prerequisites
brew install kubectl kind helm

# 2. Create a local cluster
./scripts/create-cluster.sh

# 3. Start with Scenario 1
cd scenarios/01-k8s-basics
cat README.md
kubectl apply -f 01-pod.yaml
kubectl get pods
```

---

## Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [CNCF Cloud Native Landscape](https://landscape.cncf.io/)
- [Google SRE Book](https://sre.google/sre-book/table-of-contents/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Kubernetes Benchmarks](https://github.com/aquasecurity/kube-bench)

---

## Going Further

After completing all scenarios:

1. **Production Readiness**
   - Learn Kubernetes operators
   - Study GitOps (ArgoCD, Flux)
   - Multi-cluster management

2. **Advanced Monitoring**
   - Thanos for long-term storage
   - Cortex for horizontal Prometheus
   - Pyroscope for profiling

3. **Observability**
   - Distributed tracing (Jaeger, Tempo)
   - Log aggregation (Loki, ELK)
   - AIOps and ML for operations

4. **Certification**
   - CKA: Certified Kubernetes Administrator
   - CKAD: Certified Kubernetes Application Developer
   - CKS: Kubernetes Security Specialist

---

**Happy learning! 🚀**

Remember: Kubernetes and Monitoring are vast. Focus on fundamentals first, then explore advanced topics. The best way to learn is by doing.
