# Step 2: Secrets

## Understanding Secrets

Secrets store sensitive data:
- Passwords
- API keys
- Tokens
- Certificates
- SSH keys

**Security notes:**
- Base64 encoded (not encrypted by default)
- Stored in etcd
- Can be encrypted at rest (requires configuration)
- Access controlled via RBAC

## Creating Secrets

### Method 1: From literals
```bash
kubectl create secret generic app-secret \
  --from-literal=password=mysecretpassword \
  --from-literal=api-key=sk_live_abc123
```

### Method 2: From a file
```bash
kubectl create secret tls my-tls-secret \
  --cert=tls.crt \
  --key=tls.key
```

### Method 3: From YAML manifest
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: bXlzZWNyZHBhc3N3b3Jk  # base64 encoded
  api-key: c2tfbGl2ZV9hYmMxMjM=
```

## Using Secrets

### As Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sh", "-c", "echo Password: $PASSWORD; sleep 3600"]
    env:
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
```

### As Volume Mount

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-demo
spec:
  containers:
  - name: demo
    image: nginx:alpine
    volumeMounts:
    - name: tls
      mountPath: /etc/tls
      readOnly: true
  volumes:
  - name: tls
    secret:
      secretName: my-tls-secret
```

## Your Task

1. Create a Secret with sensitive data
2. Use the Secret as environment variables
3. Mount the Secret as files in a pod

## Quick Check

Test your understanding:

1. Are Secrets encrypted by default in Kubernetes? (No - they're only base64 encoded. You need to configure encryption at rest for actual encryption)

2. How do you decode a Secret value? (Use echo -n "value" | base64 -d to decode the base64-encoded value)

3. What's the difference between generic and TLS Secrets? (generic is for arbitrary data; TLS is specifically for certificates/private key pairs)

4. Why use Secrets instead of environment variables in pod spec? (Secrets provide access control via RBAC, can be encrypted at rest, and separate sensitive data from pod specs)

5. How can you verify a Secret is mounted correctly? (Use kubectl exec to run commands inside the pod, like ls /etc/tls or cat /etc/tls/tls.key)
