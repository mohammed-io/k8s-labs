#!/bin/bash
set -e

echo "=== Kubernetes Networking Lab Verification ==="

# Check if cluster is running
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Cluster not running"
    exit 1
fi

echo "✅ Cluster is running"

# Check for services
if kubectl get service api -n default > /dev/null 2>&1; then
    echo "✅ API service exists"
else
    echo "⚠️  API service not found"
fi

# Check for ingress
if kubectl get ingress myapp-ingress -n default > /dev/null 2>&1; then
    echo "✅ Ingress resource exists"
else
    echo "⚠️  Ingress not found"
fi

echo "=== Verification complete ==="
