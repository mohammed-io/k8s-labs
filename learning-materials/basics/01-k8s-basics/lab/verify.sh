#!/bin/bash
set -e

echo "=== Kubernetes Basics Verification ==="
echo ""

# Check kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi
echo "✅ kubectl is installed"

# Check cluster connection
if ! kubectl get nodes &> /dev/null; then
    echo "❌ Cannot connect to cluster. Check kubeconfig."
    exit 1
fi
echo "✅ Cluster is accessible"

# Check deployment exists
if kubectl get deployment web-deployment &> /dev/null; then
    echo "✅ Deployment exists"
else
    echo "❌ Deployment not found. Run: kubectl apply -f deployment.yaml"
    exit 1
fi

# Check service exists
if kubectl get service web-service &> /dev/null; then
    echo "✅ Service exists"
else
    echo "❌ Service not found. Run: kubectl apply -f service.yaml"
    exit 1
fi

# Check replicas
REPLICAS=$(kubectl get deployment web-deployment -o jsonpath='{.spec.replicas}')
READY_REPLICAS=$(kubectl get deployment web-deployment -o jsonpath='{.status.readyReplicas}')

if [ "$REPLICAS" -eq "$READY_REPLICAS" ] && [ "$READY_REPLICAS" -ge 1 ]; then
    echo "✅ All $READY_REPLICAS replicas are ready"
else
    echo "⚠️  Replicas: $READY_REPLICAS/$REPLICAS ready"
fi

# Check service endpoints
ENDPOINTS=$(kubectl get endpoints web-service -o jsonpath='{.subsets[*].addresses[*]}' | wc -w)
if [ "$ENDPOINTS" -ge 1 ]; then
    echo "✅ Service has $ENDPOINTS endpoint(s)"
else
    echo "❌ Service has no endpoints. Check pod labels match service selector."
    exit 1
fi

# Test service connectivity
if kubectl run curl-test --image=curlimages/curl -i --rm --restart=Never -- curl -s http://web-service > /dev/null 2>&1; then
    echo "✅ Service is accessible"
else
    echo "⚠️  Service connectivity test failed"
fi

echo ""
echo "=== All Checks Passed! ==="
echo ""
echo "Resources:"
kubectl get pods -l app=web
echo ""
kubectl get service web-service
