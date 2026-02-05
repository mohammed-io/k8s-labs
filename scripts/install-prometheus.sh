#!/bin/bash
# Kubernetes & Monitoring Lab - Prometheus Installation Script
# Installs Prometheus Operator and related components

set -e

NAMESPACE="${NAMESPACE:-monitoring}"

echo "=========================================="
echo "Installing Prometheus Stack"
echo "=========================================="
echo ""
echo "Namespace: $NAMESPACE"
echo ""

# Add Helm repo
echo "Adding Prometheus community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update > /dev/null 2>&1

# Check if prometheus-community repo was added successfully
if ! helm repo list | grep -q "prometheus-community"; then
    echo "Error: Failed to add Helm repo"
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Install kube-prometheus-stack
echo ""
echo "Installing kube-prometheus-stack..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.retention=15d \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set defaultRules.install=true \
  --set kube-state-metrics.enabled=true

# Wait for pods to be ready
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n "$NAMESPACE" --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n "$NAMESPACE" --timeout=300s

echo ""
echo "=========================================="
echo "Prometheus stack installed!"
echo "=========================================="
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 3000:80"
echo "  Open: http://localhost:3000"
echo "  Default credentials: admin / prom-operator"
echo ""
echo "Access Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-operated 9090:9090"
echo "  Open: http://localhost:9090"
echo ""
