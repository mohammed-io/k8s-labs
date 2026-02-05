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

# Create the deployment
kubectl apply -f deployment.yaml

# Create the service
kubectl apply -f service.yaml

# Verify
kubectl get pods,deployments,services
```

## Files

- `deployment.yaml` - Starter deployment YAML
- `service.yaml` - Starter service YAML
- `verify.sh` - Automated verification script

## Cleanup

```bash
kubectl delete -f service.yaml,deployment.yaml
```
