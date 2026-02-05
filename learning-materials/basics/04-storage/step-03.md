# Step 3: StatefulSets

---

## Understanding StatefulSets

StatefulSets are designed for stateful applications that need:
- Stable, unique network identifiers
- Stable persistent storage
- Ordered, graceful deployment and scaling

### Deployment vs StatefulSet

| Feature | Deployment | StatefulSet |
|---------|-----------|-------------|
| **Pod names** | Random (hash) | Numbered (web-0, web-1) |
| **Pod identities** | Ephemeral | Stable |
| **Storage** | Shared PVCs | Each pod gets its own PVC |
| **Scaling** | Any order | Ordered (0→1→2, 2→1→0) |
| **Service** | Any Service | Requires headless Service |
| **Use case** | Stateless apps | Databases, clusters |

### StatefulSet Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     StatefulSet                          │
│                   serviceName: postgres                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐               │
│  │postgres-0│   │postgres-1│   │postgres-2│               │
│  │         │   │         │   │         │               │
│  │ PVC:    │   │ PVC:    │   │ PVC:    │               │
│  │data-0   │   │data-1   │   │data-2   │               │
│  └────┬────┘   └────┬────┘   └────┬────┘               │
│       │             │             │                     │
│       └─────────────┴─────────────┘                     │
│                     │                                   │
│                     ▼                                   │
│            ┌─────────────────┐                          │
│            │ Headless Service│                          │
│            │  postgres       │                          │
│            └─────────────────┘                          │
│                     │                                   │
│          DNS: postgres-0.postgres.default.svc           │
│              postgres-1.postgres.default.svc             │
│              postgres-2.postgres.default.svc             │
└─────────────────────────────────────────────────────────┘
```

## Headless Service Requirement

StatefulSets require a headless service for stable network identities:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

### Why Headless?

With headless service, DNS returns all pod IPs:
```
postgres.default.svc.cluster.local → A records for all pods
postgres-0.postgres.default.svc.cluster.local → Specific pod
postgres-1.postgres.default.svc.cluster.local → Specific pod
```

## StatefulSet Definition

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres  # Must match headless service
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_PASSWORD
          value: "example"
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:  # Each pod gets its own PVC
  - metadata:
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
```

## Your Task: Deploy a StatefulSet

1. Create the headless service:
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

2. Create the StatefulSet:
```yaml
# statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_PASSWORD
          value: "example"
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
```

3. Apply and observe:
```bash
kubectl apply -f service.yaml
kubectl apply -f statefulset.yaml

# Watch pods being created in order
kubectl get pods -l app=postgres -w

# Check PVCs
kubectl get pvc
```

Notice PVCs are named: `data-postgres-0`, `data-postgres-1`, `data-postgres-2`

4. Test DNS:
```bash
kubectl run dns --image=nicolaka/netshoot -i --rm --restart=Never -- \
  nslookup postgres-0.postgres
```

## Scaling StatefulSets

StatefulSets scale in order:

```bash
# Scale up
kubectl scale statefulset postgres --replicas=5
# Pods created: postgres-3, postgres-4 (in order)

# Scale down
kubectl scale statefulset postgres --replicas=2
# Pods deleted: postgres-4, postgres-3 (reverse order)
```

## Updating StatefulSets

Three update strategies:

| Strategy | Behavior |
|----------|----------|
| **RollingUpdate** (default) | Updates pods in reverse order (5→4→3→2→1→0) |
| **OnDelete** | Only updates when pods are manually deleted |
| **RollingUpdate** with partition | Updates pods >= partition only |

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2  # Only postgres-2 and above update
```

---

## Quick Check

Test your understanding:

1. Why do StatefulSets need a headless service? (To provide stable network identities with DNS records for each pod, allowing pods to find each other reliably)

2. How are PVCs named in a StatefulSet? (Using the pattern {volumeClaimTemplate-name}-{statefulset-name}-{ordinal}, e.g., data-postgres-0)

3. What's the difference in scaling between Deployments and StatefulSets? (Deployments scale indiscriminately; StatefulSets scale up in order 0→1→2 and down in reverse order)

4. What is the volumeClaimTemplates field? (A template that creates a unique PVC for each pod in the StatefulSet with stable storage)

5. How do StatefulSet pods address each other? (Using stable DNS names: {pod-name}.{service-name}.{namespace}.svc.cluster.local)

---

**Continue to `solution.md`**
