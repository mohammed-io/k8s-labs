# Solution: Kubernetes Networking

## Complete Manifests

### Step 1: Services

#### Deployment
```yaml
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

#### ClusterIP Service
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
    protocol: TCP
```

#### Headless Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-headless
spec:
  clusterIP: None
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
```

#### NodePort Service
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
    nodePort: 30080
```

#### LoadBalancer Service
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

### Step 2: Ingress

#### Web Deployment and Service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo:latest
        args:
        - "-text=Hello from Web"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

#### Path-Based Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
```

#### Host-Based Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-host-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
```

### Step 3: Network Policies

#### Test Pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
  - name: web
    image: nginx:alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: api
  labels:
    app: api
spec:
  containers:
  - name: api
    image: hashicorp/http-echo:latest
    args: ["-text=API Response", "-listen=:8080"]
    ports:
    - containerPort: 8080
```

#### Default Deny All
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

#### Allow Web to API
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
```

#### Allow DNS and External Access
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-external
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
  # Allow external HTTPS
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
```

## Explanation

### Services

| Service Type | Use Case | Accessible From |
|--------------|----------|-----------------|
| **ClusterIP** | Internal communication | Within cluster only |
| **NodePort** | External access (dev/test) | Node IP:Port (30000-32767) |
| **LoadBalancer** | Production external access | Cloud load balancer IP |
| **ExternalName** | DNS alias | DNS CNAME mapping |

### Ingress

Ingress provides HTTP/HTTPS layer 7 routing:
- **Path-based**: Routes based on URL path (`/api`, `/web`)
- **Host-based**: Routes based on Host header (`api.example.com`)
- **Annotations**: Controller-specific features (rewrite-target, CORS, rate limiting)

### Network Policies

- **Default deny**: Best practice for security - deny all, then allow specific traffic
- **Pod selector**: Determines which pods the policy applies to
- **Ingress rules**: Controls incoming traffic to pods
- **Egress rules**: Controls outgoing traffic from pods

## Testing

```bash
# Apply all manifests
kubectl apply -f .

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# Check network policies
kubectl get networkpolicy

# Test service discovery
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://api.default.svc.cluster.local

# Test ingress (add to /etc/hosts first)
curl -H "Host: myapp.local" http://localhost/web

# Test network policies
kubectl exec web -- curl http://api:8080
```

## Key Concepts Demonstrated

| Concept | Why It Matters |
|---------|----------------|
| **Service abstraction** | Decouples consumers from dynamic pod IPs |
| **DNS-based discovery** | Enables service-to-service communication |
| **Ingress consolidation** | Single entry point for multiple services |
| **Network policy security** | Implements zero-trust networking model |
| **Layer 7 routing** | Advanced HTTP features not available with Services |
