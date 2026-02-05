# Step 2: Kubernetes Ingress

---

## Understanding Ingress

Ingress manages external access to services, typically HTTP/HTTPS. Ingress can provide:
- Load balancing
- SSL/TLS termination
- Name-based virtual hosting
- Path-based routing

### Ingress vs Service

```
Without Ingress:                  With Ingress:
┌─────┐ ┌─────┐ ┌─────┐           ┌─────────────┐
│ LB  │ │ LB  │ │ LB  │           │   Ingress   │
├─────┤ ├─────┤ ├─────┤           │  Controller │
│web  │ │api  │ │admin│           └──────┬──────┘
└─────┘ └─────┘ └─────┘                   │
                                      ┌────┴────┐
                                      ▼         ▼
                                   ┌────┐    ┌────┐
                                   │web │    │api │
                                   └────┘    └────┘
```

### Ingress Architecture

```
┌──────────────────────────────────────────────────────────┐
│                       Internet                           │
│                          │                               │
│                          ▼                               │
│                   ┌──────────────┐                       │
│                   │   Ingress    │                       │
│                   │  Controller  │                       │
│                   │   (nginx)    │                       │
│                   └──────┬───────┘                       │
│                          │                               │
│         ┌────────────────┼────────────────┐              │
│         ▼                ▼                ▼              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐          │
│  │  Service │    │  Service │    │  Service │          │
│  │   /api   │    │   /web   │    │  /admin  │          │
│  └──────────┘    └──────────┘    └──────────┘          │
└──────────────────────────────────────────────────────────┘
```

## Installing the Ingress Controller

Before using Ingress, you need an Ingress controller. NGINX Ingress is popular:

```bash
# For kind cluster
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

# For minikube
minikube addons enable ingress

# Verify
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## Path-Based Routing

Route traffic based on the URL path:

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

### Path Types

| PathType | Behavior | Example |
|----------|----------|---------|
| `Exact` | Exact path match | `/api` matches `/api` only |
| `Prefix` | Prefix-based match | `/api` matches `/api`, `/api/v1` |
| `ImplementationSpecific` | Controller decides | Varies by controller |

## Host-Based Routing

Route traffic based on the Host header:

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

## Your Task: Create Ingress Rules

First, create two services to route to:

```yaml
# web-deployment.yaml
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

Create `ingress.yaml` for path-based routing:

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
      # TODO: Add path for /web routing to web service
      # TODO: Add path for /api routing to api service
```

Apply and test:
```bash
kubectl apply -f ingress.yaml

# Add entry to /etc/hosts or use Host header
curl -H "Host: myapp.local" http://localhost/web
curl -H "Host: myapp.local" http://localhost/api
```

## Ingress Annotations

NGINX Ingress supports many annotations for customization:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    # Rewrite path
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    
    # Enable CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    
    # Rate limiting
    nginx.ingress.kubernetes.io/limit-rps: "10"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api
            port:
              number: 80
```

---

## Quick Check

Test your understanding:

1. What does Ingress provide that Services don't? (HTTP/HTTPS routing, load balancing, SSL termination, name-based and path-based routing in a single resource)

2. What's the difference between pathType: Exact and Prefix? (Exact matches only the specific path; Prefix matches the path and everything under it)

3. Why do you need an Ingress controller? (Ingress is just a configuration resource; the Ingress controller (like nginx) actually implements the routing logic)

4. How does host-based routing work? (Routes based on the Host HTTP header, allowing different domains to route to different services)

5. What are Ingress annotations used for? (Controller-specific configuration like path rewriting, CORS, rate limiting, authentication)

---

**Continue to `step-03.md`**
