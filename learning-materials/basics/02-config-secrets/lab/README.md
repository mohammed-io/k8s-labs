# Kubernetes ConfigMaps & Secrets Lab

## Setup

Ensure your cluster is running:
```bash
kubectl cluster-info
```

## Lab Files

The `manifests/` directory contains starter YAML files with TODO sections.

## Verification

Run the verification script:
```bash
chmod +x verify.sh
./verify.sh
```

## Cleanup

Remove resources when done:
```bash
kubectl delete configmap app-config
kubectl delete secret app-secret
```
