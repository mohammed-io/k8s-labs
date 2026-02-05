#!/bin/bash
# Kubernetes & Monitoring Lab - Lab Cleanup Script
# Removes all resources created during the lab

set -e

echo "=========================================="
echo "Kubernetes & Monitoring Lab"
echo "Cleanup Script"
echo "=========================================="
echo ""

read -p "This will delete all lab resources. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting"
    exit 0
fi

echo ""
echo "Deleting scenarios..."

# Function to delete scenario resources
delete_scenario() {
    local scenario=$1
    if [ -d "scenarios/$scenario" ]; then
        echo "  Cleaning up $scenario..."
        # Delete all YAML files in the scenario
        find "scenarios/$scenario" -name "*.yaml" -exec kubectl delete -f {} \; 2>/dev/null || true
        # Delete manifests if they exist
        find "scenarios/$scenario" -path "*/manifests/*.yaml" -exec kubectl delete -f {} \; 2>/dev/null || true
    fi
}

# Delete all scenarios
for i in {01..10}; do
    scenario=$(ls -d scenarios/$i-* 2>/dev/null | head -1)
    if [ -n "$scenario" ]; then
        delete_scenario "$scenario"
    fi
done

echo ""
echo "Deleting monitoring stack..."
helm uninstall prometheus -n monitoring 2>/dev/null || echo "  Prometheus not installed"

echo ""
echo "Deleting namespaces..."
kubectl delete namespace monitoring --ignore-not-found=true
kubectl delete namespace tracing --ignore-not-found=true

echo ""
read -p "Delete the kind cluster too? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kind delete cluster --name lab
    echo "Kind cluster deleted"
fi

echo ""
echo "=========================================="
echo "Cleanup complete!"
echo "=========================================="
