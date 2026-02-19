#!/bin/bash
set -euo pipefail

echo "=== ConfigMaps & Secrets Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get configmap app-config >/dev/null 2>&1 || { echo "❌ Missing configmap/app-config"; exit 1; }
kubectl get secret app-secret >/dev/null 2>&1 || { echo "❌ Missing secret/app-secret"; exit 1; }

cfg_keys=$(kubectl get configmap app-config -o jsonpath='{.data}' | wc -c | tr -d ' ')
sec_keys=$(kubectl get secret app-secret -o jsonpath='{.data}' | wc -c | tr -d ' ')

if [ "$cfg_keys" -le 2 ]; then
  echo "❌ configmap/app-config appears empty"
  exit 1
fi
if [ "$sec_keys" -le 2 ]; then
  echo "❌ secret/app-secret appears empty"
  exit 1
fi

echo "✅ ConfigMap and Secret exist with data"
echo "=== All checks passed ==="
