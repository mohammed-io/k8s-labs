# Step 2: Security and Disaster Recovery

---

## Resource Quotas

Limit resource usage per namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: production
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "5"
```

## Limit Ranges

Set default resource limits:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
```

## Network Policies

Restrict pod-to-pod communication:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 80
```

## Pod Security Policies (or Pod Security Standards)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Backup Strategy

| Type | What | How |
|------|------|-----|
| **etcd** | Cluster state | `etcdctl snapshot save` |
| **Applications** | User data | Database dumps, object storage |
| **Configuration** | GitOps | Git repository |

### Velero for Backup/Restore

```bash
# Install Velero
velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.5.0 \
  --bucket my-backups --secret-file ./credentials-velero \
  --backup-location-config region=us-west-2

# Create backup
velero backup create myapp-backup --selector app=myapp

# Schedule backups
velero schedule create daily --schedule="0 2 * * *"

# Restore
velero restore create --from-backup myapp-backup
```

## Disaster Recovery Plan

1. **Define RPO/RTO**: How much data can you lose? How fast must you recover?
2. **Document procedures**: Runbooks for common failure scenarios
3. **Practice DR drills**: Regularly test restoration procedures
4. **Multi-region**: Consider multi-cluster for critical services

---

## Quick Check

1. What's the difference between ResourceQuota and LimitRange? (ResourceQuota limits total resources in a namespace; LimitRange sets min/max/default for individual containers)

2. Why use network policies? (To implement zero-trust networking by controlling which pods can communicate, reducing blast radius of compromises)

3. What are Pod Security Standards? (Kubernetes built-in controls (baseline, restricted) to enforce pod security settings like running as non-root, dropping capabilities)

4. What's Velero used for? (Backup and restore of Kubernetes resources and persistent volumes, with scheduling and cluster migration capabilities)

5. What's the difference between RPO and RTO? (RPO is Recovery Point Objective - max acceptable data loss; RTO is Recovery Time Objective - max acceptable downtime)

---

**Continue to `solution.md`**
