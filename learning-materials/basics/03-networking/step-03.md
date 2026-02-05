# Step 3: Network Policies

---

## Understanding Network Policies

By default, Kubernetes allows all traffic between pods. Network Policies let you control traffic flow for security.

### Default Behavior vs. With Network Policy

```
Default (Allow All):           With Network Policy:
                                
┌─────────────────────────┐     ┌─────────────────────────┐
│                         │     │                         │
│    Any pod              │     │    Only allowed         │
│    can reach            │     │    traffic flows         │
│    any pod              │     │                         │
│                         │     │ X───────┐ X───────┐     │
│ ┌───┐ ┌───┐ ┌───┐      │     │ │       │ │       │     │
│ │ A │ │ B │ │ C │      │     │ ▼       │ ▼       │     │
│ └───┘ └───┘ └───┘      │     │ ┌───┐   │ ┌───┐   │     │
│                         │     │ │ A │   │ │ B │   │     │
│                         │     │ └───┘   │ └───┘   │     │
└─────────────────────────┘     │         │         │     │
                                └─────────┴─────────┘     │
                                ┌───┐                     │
                                │ C │                     │
                                └───┘                     │
└─────────────────────────────────────────────────────────┘
```

### Network Policy Model

Network policies use **allow** rules (not deny):
- If no policies exist: all traffic allowed
- If policies exist: only specified traffic allowed (whitelist model)
- Policies are additive (multiple policies can apply)

## Policy Structure

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: example-policy
spec:
  podSelector:              # Which pods this applies to
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress                 # Incoming traffic
  - Egress                  # Outgoing traffic
  ingress:                  # Ingress rules (allow these)
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - protocol: TCP
      port: 80
  egress:                   # Egress rules (allow these)
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

## Default Deny All

A common pattern: deny all traffic, then explicitly allow what's needed.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}           # Empty selector = all pods
  policyTypes:
  - Ingress
  - Egress
```

After applying this, all pods are isolated. Then create specific allow policies.

## Allow Specific Ingress

Allow only web pods to reach api pods:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      app: api              # Applies to api pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web          # Only from web pods
    ports:
    - protocol: TCP
      port: 8080
```

### Matching Sources

| From Clause | Matches |
|-------------|---------|
| `podSelector` | Pods in the same namespace |
| `namespaceSelector` | All pods in matching namespaces |
| `podSelector` + `namespaceSelector` | Pods in matching namespaces with matching labels |
| `ipBlock` | Specific IP ranges (external traffic) |

## Allow Egress to Services

Allow api pods to reach database and external APIs:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-egress
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Egress
  egress:
  # Allow to database
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS (required for external access)
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow external HTTPS
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8      # Exclude private ranges
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
```

## Your Task: Create Network Policies

1. First, deploy test pods:
```yaml
# web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
  - name: web
    image: nginx:alpine
---
# api.yaml
apiVersion: v1
kind: Pod
metadata:
  name: api
  labels:
    app: api
spec:
  containers:
  - name: api
    image: hashicorp/http-echo:latest
    args: ["-text=API Response", "-listen=:8080"]
    ports:
    - containerPort: 8080
```

2. Test connectivity (should work):
```bash
kubectl exec web -- curl http://api:8080
```

3. Create `default-deny.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

4. Test again (should fail):
```bash
kubectl exec web -- curl http://api:8080
```

5. Create `allow-web-to-api.yaml`:
```yaml
# TODO: Create policy allowing web pods to reach api pods on port 8080
```

6. Test again (should work):
```bash
kubectl exec web -- curl http://api:8080
```

---

## Quick Check

Test your understanding:

1. What's the default network behavior in Kubernetes? (All traffic between pods is allowed by default)

2. What happens when you create a network policy? (Only the traffic specified in the policy is allowed; everything else is denied)

3. How do you select which pods a policy applies to? (Using the podSelector field with matchLabels to select pods by their labels)

4. What's the difference between Ingress and Egress in network policies? (Ingress controls incoming traffic to pods; Egress controls outgoing traffic from pods)

5. Why is DNS access important when using network policies? (Because pods need DNS resolution to find services; if you block egress, you must explicitly allow DNS to UDP port 53)

---

**Continue to `solution.md`**
