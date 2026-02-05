# Kubernetes Networking Lab

## Setup

1. Ensure your cluster is running:
```bash
kubectl cluster-info
```

2. If using minikube, enable ingress:
```bash
minikube addons enable ingress
```

3. If using kind, install ingress controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml
```

## Lab Files

The `manifests/` directory contains starter YAML files with TODO sections. Fill in the TODOs as you work through the steps.

## Verification

Run the verification script to check your work:
```bash
chmod +x verify.sh
./verify.sh
```

## Cleanup

Remove all resources when done:
```bash
kubectl delete all --all
kubectl delete networkpolicy --all
kubectl delete ingress --all
```
