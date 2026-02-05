# Step 1: Pods and Deployments

## Understanding Pods

A Pod is the smallest deployable unit in Kubernetes. It wraps one or more containers that should be managed together.

**Key characteristics:**
- Pods are **ephemeral** (they can be recreated at any time)
- Pods have **unique IP addresses** (IP changes when pod restarts)
- Pods can contain **multiple containers** (sidecars, ambassadors, adapters)
- Pods should typically be managed by **higher-level constructs** (Deployments)

### Pod Lifecycle

```
Pending → Running → Succeeded
                     ↓
                  Failed
```

## Understanding Deployments

Deployments provide:
- **Declarative updates** for Pods and ReplicaSets
- **Scaling** (horizontal scaling with replicas)
- **Rolling updates** (zero-downtime deployments)
- **Rollback capability** (undo failed updates)

| Feature | Pods | Deployments |
|---------|------|-------------|
| Self-healing | No | Yes |
| Scaling | Manual | Auto/Manual |
| Rolling updates | No | Yes |
| Production use | Rare | Yes |

## Your Task

1. **Create a simple Pod**:
   - Name: `nginx-pod`
   - Image: `nginx:1.25`
   - Port: 80

2. **Create a Deployment**:
   - Name: `web-deployment`
   - Replicas: 3
   - Label selector: `app=web`
   - Image: `nginx:1.25`
   - Port: 80

3. **Verify**:
   - Check pod status: `kubectl get pods`
   - Check deployment: `kubectl get deployments`
   - Describe a pod: `kubectl describe pod <name>`

## Example Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
```

## Example Deployment YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
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
```

## Scaling and Updates

```bash
# Scale to 5 replicas
kubectl scale deployment/web-deployment --replicas=5

# Update image (rolling update)
kubectl set image deployment/web-deployment nginx=nginx:1.26

# Check rollout status
kubectl rollout status deployment/web-deployment

# Rollback if needed
kubectl rollout undo deployment/web-deployment
```

## Quick Check

Test your understanding:

1. What's the smallest deployable unit in Kubernetes? (A Pod - which wraps one or more containers)

2. Why are pods considered ephemeral? (They can be recreated at any time - their IP addresses change when they restart)

3. What does a Deployment provide that Pods don't? (Self-healing, scaling, rolling updates, and rollback capability)

4. What's the purpose of the label selector in a Deployment? (It identifies which pods to manage - pods with matching labels belong to the deployment)

5. What happens during a rolling update? (Pods are replaced one by one with new versions, ensuring zero downtime)
