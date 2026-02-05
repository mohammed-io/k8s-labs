#!/bin/bash
set -e
echo "=== Verification ==="
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Cluster not running"
    exit 1
fi
echo "✅ Cluster is running"
echo "=== Verification complete ==="
