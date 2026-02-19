#!/bin/bash
set -euo pipefail

echo "=== Storage Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

pv_count=$(kubectl get pv --no-headers 2>/dev/null | wc -l | tr -d ' ')
pvc_count=$(kubectl get pvc --no-headers 2>/dev/null | wc -l | tr -d ' ')
sts_count=$(kubectl get statefulset --no-headers 2>/dev/null | wc -l | tr -d ' ')

[ "$pv_count" -ge 1 ] || { echo "❌ No PersistentVolume found"; exit 1; }
[ "$pvc_count" -ge 1 ] || { echo "❌ No PersistentVolumeClaim found"; exit 1; }
[ "$sts_count" -ge 1 ] || { echo "❌ No StatefulSet found"; exit 1; }

echo "✅ Found PV(s), PVC(s), and StatefulSet(s)"
echo "=== All checks passed ==="
