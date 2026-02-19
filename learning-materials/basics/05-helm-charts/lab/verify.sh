#!/bin/bash
set -euo pipefail

echo "=== Helm Charts Verification ==="

command -v helm >/dev/null 2>&1 || { echo "❌ helm not found"; exit 1; }

chart_dir="manifests"
[ -f "$chart_dir/Chart.yaml" ] || { echo "❌ Missing manifests/Chart.yaml"; exit 1; }
[ -f "$chart_dir/values.yaml" ] || { echo "❌ Missing manifests/values.yaml"; exit 1; }

helm lint "$chart_dir" >/dev/null 2>&1 || { echo "❌ helm lint failed for $chart_dir"; exit 1; }

echo "✅ Helm chart files exist and lint successfully"
echo "=== All checks passed ==="
