# Step 2: VPA and PodDisruptionBudget

---

## Vertical Pod Autoscaler (VPA)

VPA automatically adjusts pod resource requests based on actual usage.

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: web-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  updatePolicy:
    updateMode: Auto  # or Off or Recreate
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      minAllowed:
        cpu: 100m
        memory: 100Mi
      maxAllowed:
        cpu: 1
        memory: 1Gi
      controlledResources: ['cpu', 'memory']
```

| Update Mode | Behavior |
|-------------|----------|
| **Auto** | Updates pods during their lifecycle |
| **Recreate** | Only updates on pod restart |
| **Off** | Only recommends, doesn't apply |

## PodDisruptionBudget

PDB limits how many pods can be down simultaneously during voluntary disruptions.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 2  # At least 2 pods must always be available
  # OR
  # maxUnavailable: 1  # At most 1 pod can be unavailable
  selector:
    matchLabels:
      app: web
```

Use cases:
- **Node maintenance**: Prevents all pods from being evicted
- **Cluster upgrades**: Ensures service continuity
- **Autoscaling**: Works with HPA to maintain availability

---

## Quick Check

1. What's the difference between HPA and VPA? (HPA scales the number of pods horizontally; VPA adjusts resource requests vertically)

2. When should you NOT use VPA with HPA? (Generally they conflict - VPA changing resources while HPA scales pods can cause issues. Use one or the other typically.)

3. What's a PodDisruptionBudget for? (To ensure a minimum number of pods remain available during voluntary disruptions like node maintenance or pod eviction)

4. What's the difference between minAvailable and maxUnavailable in PDB? (minAvailable specifies at least N pods must be available; maxUnavailable specifies at most N pods can be unavailable)

5. What update modes does VPA support? (Auto - updates during pod lifecycle; Recreate - only on restart; Off - recommends only)

---

**Continue to `solution.md`**
