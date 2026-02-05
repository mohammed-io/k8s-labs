# Solution: Kubernetes Basics

## Complete YAML Files

### Pod (pod.yaml)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
      name: http
```

### Deployment (deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
```

### Service (service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    name: http
```

## Commands

```bash
# Apply everything
kubectl apply -f pod.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check resources
kubectl get pods,deployments,services

# Get detailed info
kubectl describe deployment web-deployment
kubectl describe pod -l app=web

# Test the service
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl http://web-service

# Scale deployment
kubectl scale deployment web-deployment --replicas=5

# Update image (rolling update)
kubectl set image deployment/web-deployment nginx=nginx:1.26
kubectl rollout status deployment/web-deployment

# Rollback
kubectl rollout undo deployment/web-deployment

# Cleanup
kubectl delete -f service.yaml,deployment.yaml,pod.yaml
```

## Key Concepts Demonstrated

| Concept | How It's Shown |
|---------|----------------|
| Pods | Single nginx container |
| Deployments | 3 replicas with self-healing |
| Services | ClusterIP with label selector |
| Scaling | kubectl scale command |
| Rolling Updates | kubectl set image + rollout status |
| Rollback | kubectl rollout undo |
