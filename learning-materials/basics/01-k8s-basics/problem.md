---
name: "Kubernetes Basics"
category: "basics"
difficulty: "beginner"
time: "45 minutes"
concepts: ["pods", "deployments", "services", "kubectl"]
---

# Kubernetes Basics

## Scenario

You're deploying your first application to Kubernetes. The application consists of a web frontend (nginx) that needs to be accessible to users.

## Architecture

```
┌─────────────────────────────────────┐
│         Kubernetes Cluster           │
│                                     │
│  ┌──────────────────────────────┐  │
│  │    Deployment (3 replicas)    │  │
│  │  ┌────┐ ┌────┐ ┌────┐       │  │
│  │  │Pod1 │ │Pod2 │ │Pod3│       │  │
│  │  │nginx│ │nginx│ │nginx│       │  │
│  │  └────┘ └────┘ └────┘       │  │
│  └──────────────────────────────┘  │
│              │                     │
│  ┌───────────▼──────────────┐     │
│  │     Service (ClusterIP)   │     │
│  └───────────────────────────┘     │
└─────────────────────────────────────┘
```

## Requirements

Build a basic Kubernetes deployment:

1. **Pod**: Single nginx container to understand the basic unit
2. **Deployment**: 3 replicas with rolling update capability
3. **Service**: Expose the deployment internally using ClusterIP
4. **Troubleshooting**: Debug a failing pod

## Constraints

- Use nginx:1.25 as the base image
- Service must selector-match pods with label `app=web`
- Container port: 80
- All resources must be in the `default` namespace

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `replica_count` | 3 | Number of pod replicas |
| `image` | nginx:1.25 | Container image |
| `container_port` | 80 | Port exposed by container |

## Prerequisites

- kubectl installed and configured
- Access to a Kubernetes cluster (kind, minikube, or cloud)
- Basic understanding of containers (Docker)

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **Pods** | Smallest deployable unit in Kubernetes |
| **Deployments** | Declarative updates, scaling, rolling updates |
| **Services** | Stable networking endpoint for pods |
| **kubectl** | Command-line tool for cluster interaction |

## Getting Started

1. Ensure your cluster is running:
   ```bash
   kubectl get nodes
   ```

2. Navigate to the lab directory:
   ```bash
   cd learning-materials/basics/01-k8s-basics/lab
   ```

3. Check `step-01.md` for hints on Pods and Deployments.

4. Check `step-02.md` for hints on Services and troubleshooting.

## Verification

Run the lab verification script:
```bash
cd lab
bash verify.sh
```
