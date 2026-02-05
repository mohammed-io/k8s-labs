# Step 1: ConfigMaps

## Understanding ConfigMaps

ConfigMaps store configuration data separate from application code:
- **Key-value pairs** for simple configuration
- **Entire files** for complex configuration (nginx.conf, app.yaml)
- **NOT suitable for** passwords, keys, tokens (use Secrets)

## Creating ConfigMaps

### Method 1: From literals
```bash
kubectl create configmap app-config \
  --from-literal=database.host=postgres.example.com \
  --from-literal=database.port=5432 \
  --from-literal=cache.ttl=3600
```

### Method 2: From a file
```bash
kubectl create configmap app-yaml-config --from-file=config.yaml
```

### Method 3: From YAML manifest
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "postgres.example.com"
  database.port: "5432"
  cache.ttl: "3600"
```

## Using ConfigMaps

### As Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sh", "-c", "echo $DATABASE_HOST; echo $CACHE_TTL; sleep 3600"]
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: CACHE_TTL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: cache.ttl
```

### As Volume Mount

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-demo
spec:
  containers:
  - name: demo
    image: nginx:alpine
    volumeMounts:
    - name: config
      mountPath: /etc/config
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: app-config
```

## Your Task

1. Create a ConfigMap from literals
2. Create a ConfigMap from a file
3. Use the ConfigMap as environment variables in a pod
4. Mount the ConfigMap as a volume in a pod

## Quick Check

Test your understanding:

1. What's the main difference between ConfigMap and Secret? (ConfigMap stores non-sensitive configuration in plain text; Secret stores sensitive data with base64 encoding)

2. How do you inject a specific ConfigMap key as an environment variable? (Use valueFrom.configMapKeyRef with the ConfigMap name and key)

3. What does mounting a ConfigMap as a volume do? (Creates files in the container with the ConfigMap keys as filenames and values as file contents)

4. Why not put passwords in ConfigMaps? (ConfigMaps are stored in plain text in etcd and are easily accessible - Secrets provide at least basic access control)

5. How can you update a ConfigMap? (Use kubectl edit configmap, kubectl apply -f updated.yaml, or kubectl patch configmap)
