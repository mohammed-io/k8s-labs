# Step 2: StorageClasses and Dynamic Provisioning

---

## Understanding StorageClasses

StorageClasses enable dynamic provisioning - automatically creating PVs when PVCs are created.

### Dynamic Provisioning Flow

```
    PVC requests storage
            │
            ▼
    ┌──────────────┐
    │ StorageClass │
    │              │
    │ provisioner: │
    │   aws-ebs    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Cloud      │
    │  Provisioner │───────► Automatically creates PV
    └──────────────┘
```

### Why Dynamic Provisioning?

Without StorageClass:
1. Admin creates PV manually
2. User creates PVC
3. Kubernetes binds them

With StorageClass:
1. User creates PVC with storageClass
2. Provisioner automatically creates PV
3. Kubernetes binds them

## StorageClass Definition

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs  # Or other provisioner
parameters:
  type: gp2
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
```

### Common Provisioners

| Provisioner | Cloud/Platform | Storage Type |
|-------------|----------------|--------------|
| **kubernetes.io/aws-ebs** | AWS | EBS volumes |
| **kubernetes.io/gce-pd** | GCP | Persistent Disk |
| **kubernetes.io/azure-disk** | Azure | Azure Disk |
| **kubernetes.io/no-provisioner** | Local/Bare metal | Local storage |
| **rancher.io/local-path** | Local/bare metal | Local path |

### Volume Binding Modes

| Mode | Behavior |
|------|----------|
| **Immediate** | PV provisioned and bound immediately (may cause scheduling issues) |
| **WaitForFirstConsumer** | PV provisioned after pod is scheduled (best practice) |

## Your Task: Create a StorageClass

For local testing (minikube/kind):

```yaml
# storageclass-local.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

For cloud (AWS example):

```yaml
# storageclass-aws.yaml
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

Apply:
```bash
kubectl apply -f storageclass-local.yaml
kubectl get storageclass
```

## Creating a PVC with StorageClass

```yaml
# pvc-dynamic.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-storage  # References StorageClass
  resources:
    requests:
      storage: 1Gi
```

Apply and watch dynamic provisioning:
```bash
kubectl apply -f pvc-dynamic.yaml
kubectl get pvc -w
```

A new PV should be automatically created and bound.

## Default StorageClass

```bash
# Set default StorageClass
kubectl patch storageclass local-storage \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# PVCs without storageClassName use the default
```

## Expanding PVCs

If the StorageClass has `allowVolumeExpansion: true`:

```bash
# Edit PVC and increase storage request
kubectl edit pvc dynamic-pvc
# Change storage: 1Gi to 2Gi

# Pod needs restart to see expanded size
kubectl delete pod <pod-name>
```

---

## Quick Check

Test your understanding:

1. What's dynamic provisioning? (Automatically creating PersistentVolumes when PersistentVolumeClaims are created, using a StorageClass and provisioner)

2. What's the role of the provisioner in a StorageClass? (The provisioner determines what storage backend to use - AWS EBS, GCE PD, local storage, etc.)

3. What's the difference between Immediate and WaitForFirstConsumer binding modes? (Immediate provisions PV right away; WaitForFirstConsumer delays until a pod that needs the PVC is scheduled, enabling better pod placement decisions)

4. How do you set a default StorageClass? (Add the annotation storageclass.kubernetes.io/is-default-class: "true" to the StorageClass)

5. What are the requirements for expanding a PVC? (The StorageClass must have allowVolumeExpansion: true, and the underlying storage driver must support expansion)

---

**Continue to `step-03.md`**
