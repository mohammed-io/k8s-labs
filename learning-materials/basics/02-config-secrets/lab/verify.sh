#!/bin/bash
set -e
echo "=== Kubernetes ConfigMaps & Secrets Lab Verification ==="

# Check cluster
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Cluster not running"
    exit 1
fi
echo "✅ Cluster is running"

# Check ConfigMap
if kubectl get configmap app-config -n default > /dev/null 2>&1; then
    echo "✅ ConfigMap exists"
else
    echo "⚠️  ConfigMap not found"
fi

# Check Secret
if kubectl get secret app-secret -n default > /dev/null 2>&1; then
    echo "✅ Secret exists"
else
    echo "⚠️  Secret not found"
fi

echo "=== Verification complete ==="
