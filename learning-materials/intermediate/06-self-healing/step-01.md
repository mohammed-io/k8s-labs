# Step 1: Health Probes

---

## Understanding Probes

Kubernetes uses three types of probes to assess container health:

| Probe | Purpose | Failure Action |
|-------|---------|----------------|
| **Liveness** | Detect if container is dead | Restarts container |
| **Readiness** | Detect if container can serve traffic | Removes from Service |
| **Startup** | Detect if slow-starting app is ready | Disables liveness/readiness until ready |

## Liveness Probe

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

## Readiness Probe

```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3
```

## Startup Probe (for slow apps)

```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 30  # 30 * 5 = 150 seconds max
```

## Your Task: Add Probes to a Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
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
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
        # TODO: Add livenessProbe for /
        # TODO: Add readinessProbe for /
        # TODO: Add startupProbe for slow-starting apps
```

## HPA - Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

Apply:
```bash
kubectl apply -f hpa.yaml
kubectl get hpa
```

---

## Quick Check

1. What's the difference between liveness and readiness probes? (Liveness detects if the container needs to be restarted; readiness detects if the container should receive traffic)

2. What happens when a liveness probe fails? (The container is restarted according to its restart policy)

3. What happens when a readiness probe fails? (The pod is removed from Service endpoints and receives no traffic)

4. When should you use a startup probe? (For applications that take a long time to start up, to give them extra time before liveness/readiness kicks in)

5. What's the purpose of HPA? (To automatically scale the number of pods based on observed metrics like CPU and memory usage)

---

**Continue to `step-02.md`**
