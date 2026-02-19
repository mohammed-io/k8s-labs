#!/bin/bash
set -euo pipefail

echo "=== Monitoring Basics Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get servicemonitor myapp -n monitoring >/dev/null 2>&1 || { echo "❌ Missing servicemonitor/myapp in monitoring namespace"; exit 1; }

endpoint_port=$(kubectl get servicemonitor myapp -n monitoring -o jsonpath='{.spec.endpoints[0].port}')
endpoint_path=$(kubectl get servicemonitor myapp -n monitoring -o jsonpath='{.spec.endpoints[0].path}')
[ -n "$endpoint_port" ] || { echo "❌ ServiceMonitor endpoint port is missing"; exit 1; }
[ -n "$endpoint_path" ] || { echo "❌ ServiceMonitor endpoint path is missing"; exit 1; }

echo "✅ ServiceMonitor configured with scrape endpoint"
echo "=== All checks passed ==="
