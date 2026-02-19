# Solution: Storage in Kubernetes

## Complete Manifests

### Step 1: PV and PVC

#### PersistentVolume
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/data
```

#### PersistentVolumeClaim
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
```

#### Pod with PVC
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-demo
spec:
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
  containers:
  - name: demo
    image: nginx:alpine
    volumeMounts:
    - name: data
      mountPath: /data
```

### Step 2: StorageClass

#### Local StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

#### AWS EBS StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storage
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
```

#### Dynamic PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
```

### Step 3: StatefulSet

#### Secret for PostgreSQL
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
stringData:
  password: "change-me-in-production"
```

#### Headless Service
```yaml
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

#### StatefulSet
```yaml
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
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
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

### Additional: EmptyDir for Sharing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-demo
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "while true; do echo $(date) >> /data/log.txt; sleep 5; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    command: ["sh", "-c", "tail -f /data/log.txt"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
```

## Explanation

### PV vs PVC

| Aspect | PersistentVolume | PersistentVolumeClaim |
|--------|------------------|----------------------|
| **Scope** | Cluster-wide | Namespace-scoped |
| **Purpose** | Represents actual storage | Request for storage |
| **Used by** | None (claimed by PVC) | Pods |
| **Lifecycle** | Manual or dynamic | Created/Deleted by users |

### StorageClass Components

| Component | Purpose |
|-----------|---------|
| **Provisioner** | Determines storage backend (AWS EBS, GCE PD, etc.) |
| **Parameters** | Backend-specific settings (type, IOPS, encryption) |
| **Reclaim Policy** | What happens when PVC is deleted (Delete/Retain) |
| **Volume Binding Mode** | When PV is provisioned (Immediate/WaitForFirstConsumer) |
| **Allow Volume Expansion** | Whether PVCs can be resized |

### StatefulSet Features

| Feature | Description |
|---------|-------------|
| **Stable Network Identity** | Pod names and DNS don't change |
| **Stable Storage** | Each pod gets its own PVC via volumeClaimTemplates |
| **Ordered Deployment** | Pods start in order: 0, 1, 2... |
| **Ordered Scaling** | Scale down in reverse: 2, 1, 0 |
| **Ordered Rolling Updates** | Updates in reverse order with controlled partitioning |

## Testing

```bash
# Apply all manifests
kubectl apply -f .

# Check PV/PVC binding
kubectl get pv,pvc

# Check StatefulSet
kubectl get statefulset
kubectl get pods -l app=postgres

# Check PVCs created by StatefulSet
kubectl get pvc
# Should see: data-postgres-0, data-postgres-1, data-postgres-2

# Test DNS resolution
kubectl run dns --image=nicolaka/netshoot -i --rm --restart=Never -- \
  nslookup postgres-0.postgres

# Test persistence
kubectl exec postgres-0 -- sh -c "echo 'test' > /var/lib/postgresql/data/test.txt"
kubectl delete pod postgres-0
# Wait for pod to restart, then check file still exists
kubectl exec postgres-0 -- cat /var/lib/postgresql/data/test.txt

# Scale StatefulSet
kubectl scale statefulset postgres --replicas=5
kubectl get pods -w
# Watch postgres-3 and postgres-4 being created in order
```

## Key Concepts Demonstrated

| Concept | Why It Matters |
|---------|----------------|
| **PV/PVC separation** | Decouples storage provisioning from consumption |
| **Dynamic provisioning** | Automates storage creation with StorageClasses |
| **StatefulSet identity** | Enables reliable database clustering |
| **Ordered operations** | Critical for database bootstrap and shutdown |
| **Headless services** | Direct pod-to-pod communication for clustering |

## Best Practices

1. **Always use PVCs in production** - never use hostPath
2. **Set resource requests on PVCs** - helps scheduler make decisions
3. **Use WaitForFirstConsumer** - prevents scheduling issues
4. **Set appropriate reclaim policies** - Retain for important data
5. **Backup your PVCs** - Kubernetes doesn't do this automatically
6. **Monitor storage usage** - prevent out-of-space issues
7. **Use StatefulSets for databases** - not Deployments
8. **Test StatefulSet scaling** - understand ordered operations
