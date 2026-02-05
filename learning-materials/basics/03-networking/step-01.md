# Step 1: Kubernetes Services

---

## Understanding Services

Services provide stable networking endpoints for pods. Since pods are ephemeral and their IPs change, services abstract this away.

### Service Types

```
┌─────────────────────────────────────────────────────────┐
│                    Service Types                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ClusterIP     ─────►  Cluster internal only (default)   │
│  NodePort      ─────►  Exposed on each node's IP        │
│  LoadBalancer  ─────►  Cloud load balancer              │
│  ExternalName  ─────►  DNS CNAME record                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Service Architecture

```
                    Service (stable IP: 10.96.0.100)
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
    ┌───────┐          ┌───────┐          ┌───────┐
    │ Pod A │          │ Pod B │          │ Pod C │
    │ 10.244.1.5  │    │ 10.244.1.6  │    │ 10.244.2.3  │
    └───────┘          └───────┘          └───────┘
    
    Pods come and go, but Service IP stays constant!
```

## ClusterIP Service

The default service type. Only accessible within the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: ClusterIP  # This is the default, can be omitted
  selector:
    app: api  # Must match pod labels
  ports:
  - port: 80        # Service port
    targetPort: 8080  # Container port
    protocol: TCP
```

### Selector Matching

The service's `selector` field determines which pods are included:

```yaml
# Service selector
selector:
  app: api

# Matches pods with these labels
metadata:
  labels:
    app: api  # ✓ Match
```

## Your Task: Create a ClusterIP Service

First, create a deployment to have some pods:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: hashicorp/http-echo:latest
        args:
        - "-text=Hello from API"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
```

Apply it:
```bash
kubectl apply -f deployment.yaml
kubectl get pods -l app=api
```

Now create `clusterip-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
```

Apply and verify:
```bash
kubectl apply -f clusterip-service.yaml
kubectl get service api

# Test from within the cluster
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://api
```

## Service Discovery

Kubernetes provides DNS for service discovery. The DNS pattern is:

```
<service-name>.<namespace>.svc.cluster.local
```

Examples:
- `api.default.svc.cluster.local` - api service in default namespace
- `api.kube-system.svc.cluster.local` - api service in kube-system

Short forms work within the same namespace:
- `api` - same namespace
- `api.default` - explicit namespace
- `api.default.svc` - with service suffix

Test DNS resolution:
```bash
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://api.default.svc.cluster.local
```

## Headless Services

A headless service (clusterIP: None) doesn't get a cluster IP. Instead, DNS returns all pod IPs directly.

Useful for:
- StatefulSets (need direct pod access)
- Custom service discovery
- Database clustering

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-headless
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
```

```bash
# Check DNS - returns all pod IPs
kubectl run dns --image=nicolaka/netshoot -i --rm --restart=Never -- \
  nslookup api-headless
```

## NodePort Service

Exposes the service on each node's IP at a static port.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080  # Optional: 30000-32767 range
```

Access via `http://<node-ip>:30080`

## LoadBalancer Service

Provisions a cloud load balancer (requires cloud provider or MetalLB).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-lb
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
```

---

## Quick Check

Test your understanding:

1. What's the purpose of a Kubernetes Service? (Provides a stable network endpoint to access a group of pods, abstracting away changing pod IPs)

2. What's the difference between ClusterIP and NodePort? (ClusterIP is internal only; NodePort exposes the service on each node's IP at a static port in 30000-32767)

3. How does the service selector work? (The selector matches pod labels; pods with matching labels are included in the service)

4. What's the DNS pattern for service discovery? (<service-name>.<namespace>.svc.cluster.local, with short forms like <service-name> working within the same namespace)

5. When would you use a headless service? (When you need direct access to individual pods, like with StatefulSets or database clusters)

---

**Continue to `step-02.md`**
