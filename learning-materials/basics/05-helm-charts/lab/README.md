# Kubernetes Lab

## Setup

1. Ensure your cluster is running:
```bash
kubectl cluster-info
```

## Verification

Run the verification script:
```bash
chmod +x verify.sh
./verify.sh
```

## Cleanup

Remove resources when done:
```bash
kubectl delete all --all
```
