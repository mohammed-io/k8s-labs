# Step 1: PersistentVolumes and PersistentVolumeClaims

---

## Understanding PV and PVC

### The Relationship

PersistentVolumes (PV) are cluster resources representing actual storage. PersistentVolumeClaims (PVC) are requests for storage by users.

```
PV (Cluster Resource)          PVC (Namespace Scoped)
└───────┬───────┘              ┌────────┴───────┐
        │                      │                │
        └──────────Claim───────┘                │
                                                │
                                                ▼
                                    Pod mounts PVC
```

### Access Modes

| Access Mode | Description | Use Case |
|-------------|-------------|----------|
| **ReadWriteOnce** | Single node read/write | Most databases |
| **ReadOnlyMany** | Many nodes read-only | Content serving |
| **ReadWriteMany** | Many nodes read/write | NFS, shared file systems |

## PersistentVolume

A PV is a piece of storage in the cluster:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain  # or Delete
  hostPath:
    path: /tmp/data  # For testing only!
```

### Reclaim Policies

| Policy | Behavior |
|--------|----------|
| **Retain** | PV remains after PVC deletion (manual cleanup) |
| **Delete** | PV and underlying storage are deleted with PVC |
| **Recycle** | Deprecated - used to run rm -rf on the volume |

## PersistentVolumeClaim

A PVC claims storage from a PV:

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
  storageClassName: ""  # Empty = static provisioning
```

### Binding

Kubernetes binds PVCs to PVs based on:
1. Access mode compatibility
2. Storage capacity (PVC ≤ PV)
3. StorageClass (must match)
4. Label selectors (if specified)

## Your Task: Create and Use a PVC

1. Create a PV:
```yaml
# pv.yaml
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

2. Create a PVC:
```yaml
# pvc.yaml
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

3. Apply and check binding:
```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl get pv,pvc
```

Look for `BOUND` status.

4. Use PVC in a pod:
```yaml
# pod-with-pvc.yaml
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

5. Test persistence:
```bash
kubectl apply -f pod-with-pvc.yaml
kubectl exec pvc-demo -- sh -c "echo 'Hello World' > /data/test.txt"
cat /tmp/data/test.txt  # On node running the pod

kubectl delete pod pvc-demo
# Recreate and verify data persists
```

## Volume Types

| Type | Description | Production Ready? |
|------|-------------|-------------------|
| **hostPath** | Node's filesystem | No (testing only) |
| **emptyDir** | Empty pod-local volume | Yes (ephemeral) |
| **configMap** | Config data | Yes |
| **secret** | Sensitive data | Yes |
| **CSI** | Container Storage Interface | Yes (modern) |
| **NFS** | Network File System | Yes |
| **AWS EBS** | Amazon EBS volumes | Yes (AWS) |
| **GCE PD** | Google Persistent Disk | Yes (GCP) |
| **Azure Disk** | Azure Disk storage | Yes (Azure) |

---

## Quick Check

Test your understanding:

1. What's the difference between PV and PVC? (PV is the actual cluster storage resource; PVC is a namespace-scoped request for storage that pods use)

2. What does the storage reclaim policy Retain do? (The PV remains after PVC deletion and must be manually cleaned up; data is not automatically deleted)

3. How does Kubernetes bind PVCs to PVs? (Based on access mode compatibility, storage capacity, storageClass match, and optional label selectors)

4. What's ReadWriteOnce access mode? (Storage can be mounted as read-write by a single node)

5. Why is hostPath not recommended for production? (It's node-specific, not portable, and has security issues; data is lost if the pod moves to another node)

---

**Continue to `step-02.md`**
