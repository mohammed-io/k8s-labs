#!/bin/bash
# Kubernetes & Monitoring Lab - Cluster Creation Script
# Creates a local kind cluster with required configurations

set -e

CLUSTER_NAME="${CLUSTER_NAME:-lab}"
KIND_CONFIG="${KIND_CONFIG:-./scripts/kind-config.yaml}"

echo "=========================================="
echo "Kubernetes & Monitoring Lab"
echo "=========================================="
echo ""
echo "Creating kind cluster: $CLUSTER_NAME"
echo ""

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed"
    echo "Install with: brew install kind"
    exit 1
fi

# Check if cluster already exists
if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
    echo "Cluster '$CLUSTER_NAME' already exists"
    read -p "Delete and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing cluster..."
        kind delete cluster --name "$CLUSTER_NAME"
    else
        echo "Exiting"
        exit 0
    fi
fi

# Create kind config if it doesn't exist
if [ ! -f "$KIND_CONFIG" ]; then
    echo "Creating default kind config..."
    cat > "$KIND_CONFIG" <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
- role: worker
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    listenAddress: "127.0.0.1"
  - role: worker
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
    listenAddress: "127.0.0.1"
EOF
fi

# Create the cluster
echo "Creating cluster..."
kind create cluster --name "$CLUSTER_NAME" --config="$KIND_CONFIG"

# Verify cluster is ready
echo ""
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready nodes --timeout=300s

# Install metrics server (required for HPA)
echo ""
echo "Installing metrics server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Create namespaces
echo ""
echo "Creating namespaces..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace tracing --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=========================================="
echo "Cluster created successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Verify cluster: kubectl cluster-info"
echo "  2. Check nodes: kubectl get nodes"
echo "  3. Start with Scenario 1: cd scenarios/01-k8s-basics"
echo ""
