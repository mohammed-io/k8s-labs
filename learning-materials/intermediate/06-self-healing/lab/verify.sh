#!/bin/bash
set -euo pipefail

echo "=== Self-Healing Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get deployment web >/dev/null 2>&1 || { echo "❌ Missing deployment/web"; exit 1; }

liveness=$(kubectl get deployment web -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}')
readiness=$(kubectl get deployment web -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
[ -n "$liveness" ] || { echo "❌ Missing liveness probe on deployment/web"; exit 1; }
[ -n "$readiness" ] || { echo "❌ Missing readiness probe on deployment/web"; exit 1; }

kubectl get hpa web-hpa >/dev/null 2>&1 || { echo "❌ Missing hpa/web-hpa"; exit 1; }
kubectl get pdb web-pdb >/dev/null 2>&1 || { echo "❌ Missing pdb/web-pdb"; exit 1; }

echo "✅ Deployment probes, HPA, and PDB validated"
echo "=== All checks passed ==="
