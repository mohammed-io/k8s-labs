#!/bin/bash
set -euo pipefail

echo "=== Production-Ready Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get resourcequota compute-resources -n production >/dev/null 2>&1 || { echo "❌ Missing resourcequota/compute-resources in production namespace"; exit 1; }
kubectl get limitrange default-limits -n production >/dev/null 2>&1 || { echo "❌ Missing limitrange/default-limits in production namespace"; exit 1; }
kubectl get networkpolicy deny-all -n production >/dev/null 2>&1 || { echo "❌ Missing networkpolicy/deny-all in production namespace"; exit 1; }
kubectl get configmap alertmanager-config -n monitoring >/dev/null 2>&1 || { echo "❌ Missing configmap/alertmanager-config in monitoring namespace"; exit 1; }

echo "✅ Resource controls, network policy, and alertmanager config exist"
echo "=== All checks passed ==="
