#!/bin/bash
set -euo pipefail

echo "=== Grafana Dashboards Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get configmap myapp-dashboard -n monitoring >/dev/null 2>&1 || { echo "❌ Missing configmap/myapp-dashboard in monitoring namespace"; exit 1; }
label=$(kubectl get configmap myapp-dashboard -n monitoring -o jsonpath='{.metadata.labels.grafana_dashboard}')
[ "$label" = "1" ] || { echo "❌ configmap/myapp-dashboard must set label grafana_dashboard=1"; exit 1; }

json_key=$(kubectl get configmap myapp-dashboard -n monitoring -o jsonpath='{.data}' | grep -Eo 'dashboard\.json|myapp-dashboard\.json' || true)
[ -n "$json_key" ] || { echo "❌ Dashboard ConfigMap does not include dashboard JSON data"; exit 1; }

echo "✅ Dashboard ConfigMap label and data validated"
echo "=== All checks passed ==="
