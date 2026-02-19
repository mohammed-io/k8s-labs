#!/bin/bash
set -euo pipefail

echo "=== Networking Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get service api >/dev/null 2>&1 || { echo "❌ Missing service/api"; exit 1; }
kubectl get service api-headless >/dev/null 2>&1 || { echo "❌ Missing service/api-headless"; exit 1; }
kubectl get ingress myapp-ingress >/dev/null 2>&1 || { echo "❌ Missing ingress/myapp-ingress"; exit 1; }

cluster_ip=$(kubectl get service api-headless -o jsonpath='{.spec.clusterIP}')
if [ "$cluster_ip" != "None" ]; then
  echo "❌ service/api-headless must set clusterIP: None"
  exit 1
fi

echo "✅ Services and ingress exist"
echo "=== All checks passed ==="
