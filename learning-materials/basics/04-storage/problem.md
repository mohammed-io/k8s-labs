---
name: "Storage in Kubernetes"
category: "basics"
difficulty: "intermediate"
time: "40 minutes"
concepts: ["persistent-volume", "persistent-volume-claim", "storage-class", "statefulset"]
tools: ["kubectl", "minikube"]
---

# Storage in Kubernetes

Learn how to manage persistent storage for stateful applications.

## The Problem

You need to deploy stateful applications that require persistent data:
- **PostgreSQL database** - needs persistent storage that survives pod restarts
- **File storage** - for user uploads that must persist
- **Shared data** - between containers in the same pod

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Storage Abstraction                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────────┐        ┌─────────────────────┐    │
│  │ PersistentVolume│◄───────►│ PersistentVolume    │    │
│  │     (PV)        │  Claim  │ Claim (PVC)         │    │
│  │                 │         │                     │    │
│  │ Cluster Resource│         │ Namespace Scoped    │    │
│  │                 │         │                     │    │
│  │ • Actual storage│         │ • Request for storage   │
│  │ • Provisioned   │         │ • Used by pods       │    │
│  └─────────────────┘         └──────────┬──────────┘    │
│                                          │               │
│                                          ▼               │
│                                  ┌───────────────┐      │
│                                  │      Pod       │      │
│                                  │  mounts PVC   │      │
│                                  └───────────────┘      │
└─────────────────────────────────────────────────────────┘
```

## Requirements

1. **Persistent Volumes**: Create and manage PVs and PVCs
2. **Storage Classes**: Set up dynamic provisioning
3. **StatefulSets**: Deploy applications needing stable identity and storage
4. **Volume Types**: Use appropriate volumes for different scenarios

## Constraints

- Storage availability depends on your cluster setup
- hostPath is for testing only, not production
- StatefulSets require headless services

## Prerequisites

- ✅ Scenario 01: Kubernetes Basics (Pods, Deployments)
- ✅ Understanding of basic disk/storage concepts
- kubectl installed
- Kubernetes cluster running

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **PV/PVC** | Decouples storage from pod lifecycle |
| **StorageClass** | Enables dynamic provisioning |
| **StatefulSet** | Stable identity and storage for stateful apps |
| **EmptyDir** | Temporary shared storage between containers |

## Getting Started

```bash
# Verify your cluster is running
kubectl cluster-info

# Check available storage classes
kubectl get storageclass
```

## Verification

After completing this scenario, you should be able to:
- Create and use PersistentVolumes and PersistentVolumeClaims
- Set up StorageClasses for dynamic provisioning
- Deploy StatefulSets with persistent storage
- Choose appropriate volume types for different scenarios

---

**Start with `step-01.md`**
