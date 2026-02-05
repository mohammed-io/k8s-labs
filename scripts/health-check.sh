#!/bin/bash
# Kubernetes & Monitoring Lab - Health Check Script
# Verifies that the lab environment is properly set up

set -e

echo "=========================================="
echo "Kubernetes & Monitoring Lab"
echo "Health Check"
echo "=========================================="
echo ""

FAIL_COUNT=0

# Function to check and report
check() {
    local name=$1
    local command=$2
    local expected=${3:-"0"}

    echo -n "Checking $name... "

    if eval "$command" > /dev/null 2>&1; then
        echo "✓ OK"
        return 0
    else
        echo "✗ FAILED"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Check if kind is installed
check "kind installation" "command -v kind"

# Check if kubectl is installed
check "kubectl installation" "command -v kubectl"

# Check if helm is installed
check "helm installation" "command -v helm"

# Check if cluster exists
check "kind cluster" "kind get clusters | grep -q '^lab$'"

# Check if cluster is ready
echo -n "Checking cluster readiness... "
if kubectl wait --for=condition=ready nodes --timeout=10s 2>/dev/null; then
    echo "✓ OK"
else
    echo "⚠ Nodes not ready (may still be starting)"
fi

# Check kube-system pods
echo -n "Checking system pods... "
if kubectl get pods -n kube-system 2>/dev/null | grep -q "Running"; then
    echo "✓ OK"
else
    echo "⚠ No system pods running"
fi

# Check if metrics server is installed
check "metrics server" "kubectl get svc -n kube-system metrics-server"

# Check if monitoring namespace exists
check "monitoring namespace" "kubectl get namespace monitoring"

# Check if Prometheus is running
if kubectl get namespace monitoring > /dev/null 2>&1; then
    echo -n "Checking Prometheus pods... "
    if kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus 2>/dev/null | grep -q "Running"; then
        echo "✓ OK"
    else
        echo "⚠ Prometheus not running"
    fi

    # Check if Grafana is running
    echo -n "Checking Grafana pods... "
    if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana 2>/dev/null | grep -q "Running"; then
        echo "✓ OK"
    else
        echo "⚠ Grafana not running"
    fi
fi

echo ""
echo "=========================================="
if [ $FAIL_COUNT -eq 0 ]; then
    echo "All checks passed! ✓"
    echo "You're ready to start learning."
else
    echo "$FAIL_COUNT check(s) failed!"
    echo "Run scripts/create-cluster.sh to set up the cluster."
    echo "Run scripts/install-prometheus.sh to install monitoring."
fi
echo "=========================================="
