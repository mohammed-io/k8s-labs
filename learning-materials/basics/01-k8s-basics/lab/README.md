# Lab: Kubernetes Basics

## Setup

This lab requires a running Kubernetes cluster.

## Prerequisites

1. kubectl installed and configured
2. Kubernetes cluster running (kind, minikube, or cloud)

## Quick Start

```bash
# Check cluster connection
kubectl get nodes

# Navigate to manifests directory
cd manifests

# Create the pod (optional standalone exercise)
kubectl apply -f pod.yaml

# Create the deployment
kubectl apply -f deployment.yaml

# Create the service
kubectl apply -f service.yaml

# Verify
kubectl get pods,deployments,services
```

## Files

- `manifests/pod.yaml` - Starter pod YAML (standalone exercise)
- `manifests/deployment.yaml` - Starter deployment YAML
- `manifests/service.yaml` - Starter service YAML
- `verify.sh` - Automated verification script

## Cleanup

```bash
kubectl delete -f manifests/service.yaml
kubectl delete -f manifests/deployment.yaml
kubectl delete -f manifests/pod.yaml
```
