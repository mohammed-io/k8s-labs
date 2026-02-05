# Solution: Configuration & Secrets

## Complete YAML Files

### ConfigMap (configmap.yaml)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "postgres.example.com"
  database.port: "5432"
  cache.ttl: "3600"
  debug: "false"
```

### Secret (secret.yaml)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: bXlzZWNyZXBhc3N3b3Jk
  api-key: c2tfbGl2ZV9hYmMxMjM=
```

### Pod with ConfigMap and Secret (pod.yaml)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-demo
  labels:
    app: demo
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sh", "-c", "echo DB: $DATABASE_HOST:$DATABASE_PORT; echo Pass: $PASSWORD; sleep 3600"]
    env:
    # From ConfigMap
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.port
    - name: CACHE_TTL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: cache.ttl
    # From Secret
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: api-key
```

### Pod with Volume Mounts (pod-volume.yaml)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-demo
spec:
  containers:
  - name: demo
    image: nginx:alpine
    volumeMounts:
    - name: config
      mountPath: /etc/config
      readOnly: true
    - name: tls
      mountPath: /etc/tls
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: app-config
  - name: tls
    secret:
      secretName: app-secret
```

## Commands

```bash
# Apply everything
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pod.yaml

# Verify
kubectl get configmap,secret
kubectl describe configmap app-config
kubectl describe secret app-secret

# Check pod
kubectl get pods
kubectl describe pod config-demo

# Test environment variables
kubectl exec config-demo -- env | grep -E "DATABASE_|CACHE_|PASSWORD_|API_KEY"

# Test volume mounts
kubectl exec volume-demo -- ls -la /etc/config
kubectl exec volume-demo -- cat /etc/tls/password

# Cleanup
kubectl delete -f pod.yaml,secret.yaml,configmap.yaml
```

## Key Concepts Demonstrated

| Concept | How It's Shown |
|---------|----------------|
| ConfigMap creation | From literals and YAML |
| Secret creation | Base64 encoded sensitive data |
| Environment injection | valueFrom.configMapKeyRef and secretKeyRef |
| Volume mounting | ConfigMap and Secret as volumes |
