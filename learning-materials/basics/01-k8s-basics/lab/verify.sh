#!/bin/bash
set -euo pipefail

echo "=== Kubernetes Basics Verification ==="

if ! command -v kubectl >/dev/null 2>&1; then
  echo "❌ kubectl not found"
  exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "❌ Cluster not running"
  exit 1
fi

echo "✅ Cluster reachable"

kubectl get deployment web-deployment >/dev/null 2>&1 || { echo "❌ Missing deployment/web-deployment"; exit 1; }
kubectl get service web-service >/dev/null 2>&1 || { echo "❌ Missing service/web-service"; exit 1; }

desired=$(kubectl get deployment web-deployment -o jsonpath='{.spec.replicas}')
ready=$(kubectl get deployment web-deployment -o jsonpath='{.status.readyReplicas}')
ready=${ready:-0}
if [ "$ready" -lt 1 ]; then
  echo "❌ deployment/web-deployment has no ready replicas"
  exit 1
fi

echo "✅ deployment/web-deployment desired=$desired ready=$ready"
echo "✅ service/web-service exists"
echo "=== All checks passed ==="
