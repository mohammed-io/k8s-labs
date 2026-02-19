#!/bin/bash
set -euo pipefail

echo "=== OpenTelemetry Verification ==="

command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "❌ Cluster not running"; exit 1; }

kubectl get deployment otel-collector -n observability >/dev/null 2>&1 || { echo "❌ Missing deployment/otel-collector in observability namespace"; exit 1; }

otel_env=$(kubectl get deployment otel-collector -n observability -o jsonpath='{.spec.template.spec.containers[0].image}')
[ -n "$otel_env" ] || { echo "❌ otel-collector deployment has no container image"; exit 1; }

if kubectl get deployment myapp -n observability >/dev/null 2>&1; then
  endpoint=$(kubectl get deployment myapp -n observability -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="OTEL_EXPORTER_OTLP_ENDPOINT")].value}')
  [ -n "$endpoint" ] || { echo "❌ deployment/myapp missing OTEL_EXPORTER_OTLP_ENDPOINT"; exit 1; }
fi

echo "✅ OTEL collector deployment validated"
echo "=== All checks passed ==="
