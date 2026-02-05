# Step 2: Services and Troubleshooting

## Understanding Services

Services provide:
- **Stable network endpoint** for pods (pods have changing IPs)
- **Load balancing** across multiple pod replicas
- **Service discovery** via DNS
- **Four types**: ClusterIP (default), NodePort, LoadBalancer, ExternalName

### Service Types

```
ClusterIP     → Internal only (default)
NodePort      → Exposed on each node's IP (30000-32767)
LoadBalancer  → Cloud load balancer (requires cloud provider)
ExternalName  → DNS CNAME record (maps to external DNS)
```

### How Services Work

```
           Service (stable IP: 10.96.0.100)
                    │
        ┌───────────┼───────────┐
        │           │           │
    ┌───▼───┐  ┌───▼───┐  ┌───▼───┐
    │ Pod-1 │  │ Pod-2 │  │ Pod-3 │
    │ :IP-1 │  │ :IP-2 │  │ :IP-3 │
    └───────┘  └───────┘  └───────┘

Traffic to Service → distributes to all backend Pods
```

## Service Discovery

Kubernetes provides DNS for services:
- Pattern: `<service-name>.<namespace>.svc.cluster.local`
- Short form within namespace: `<service-name>`
- Example: `web-service` or `web-service.default.svc.cluster.local`

## Your Task

1. **Create a Service**:
   - Name: `web-service`
   - Type: ClusterIP
   - Selector: `app=web` (must match deployment pod labels)
   - Port: 80
   - TargetPort: 80

2. **Test the Service**:
   ```bash
   # Run a temporary pod to test
   kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl http://web-service
   ```

3. **Verify Endpoints**:
   ```bash
   kubectl get endpoints web-service
   ```

## Example Service YAML

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
```

## Troubleshooting

### Common Pod States

| State | Meaning | Action |
|-------|---------|--------|
| `Pending` | Pod scheduled but not running | Check resource limits, scheduler |
| `Running` | Pod is running | Normal state |
| `Succeeded` | Pod completed successfully | Normal for jobs |
| `Failed` | Pod exited with error | Check logs, events |
| `Unknown` | Cluster communication lost | Check cluster connection |

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `ImagePullBackOff` | Invalid image name/tag | Verify image exists |
| `CrashLoopBackOff` | Container exits repeatedly | Check logs for app errors |
| `ErrImageNeverPull` | Policy forbids pull | Check imagePullPolicy |
| `CreateContainerConfigError` | Invalid config | Fix pod specification |

### Troubleshooting Commands

```bash
# Get pod status
kubectl get pods

# Describe pod (detailed info + events)
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- sh

# Get pod YAML
kubectl get pod <pod-name> -o yaml

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Debugging a Broken Pod

Apply this broken pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
spec:
  containers:
  - name: broken
    image: nginx:invalid-tag
    ports:
    - containerPort: 80
```

**What to do:**
1. Apply and check status: `kubectl get pods`
2. Describe to see events: `kubectl describe pod broken-pod`
3. Look at the Events section for the error
4. Fix the image tag and reapply

## Quick Check

Test your understanding:

1. Why do we need Services instead of using Pod IPs directly? (Pod IPs are ephemeral - they change when pods restart, Services provide a stable endpoint)

2. What's the DNS name format for a service? (service-name.namespace.svc.cluster.local - or just service-name within the same namespace)

3. What does the selector in a Service do? (Determines which pods receive traffic - pods with matching labels)

4. What does `CrashLoopBackOff` mean? (The container is repeatedly crashing and restarting - check logs for application errors)

5. How do you view logs for a pod that's already restarted? (kubectl logs <pod-name> shows current logs; add --previous to see previous container's logs)
