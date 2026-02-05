# Step 2: Release Management

---

## Understanding Helm Releases

A Helm release is an instance of a chart running in a Kubernetes cluster. Each release has:
- **Unique name**: You choose this
- **Namespace**: Where resources are created
- **Revision**: Incremented on each upgrade
- **Status**: deployed, failed, pending-install, etc.

## Installing a Chart

### Dry Run First

Always test before installing:

```bash
# See what would be created
helm install myapp ./myapp --dry-run --debug

# Render templates without installing
helm template myapp ./myapp
```

### Install Commands

```bash
# Install with default values
helm install myapp ./myapp

# Install into specific namespace
helm install myapp ./myapp -n mynamespace --create-namespace

# Install with custom values file
helm install myapp ./myapp -f values-prod.yaml

# Install with inline value overrides
helm install myapp ./myapp --set replicaCount=3 --set image.tag=1.25

# Combine file and inline values (inline takes precedence)
helm install myapp ./myapp -f values-dev.yaml --set replicaCount=5
```

### Check Release Status

```bash
# List all releases
helm list

# List releases in all namespaces
helm list --all-namespaces

# Get detailed status
helm status myapp

# Get release manifest (rendered YAML)
helm get manifest myapp

# Get release values
helm get values myapp

# Get all revisions
helm history myapp
```

## Upgrading a Release

### Modifying Values

Update values.yaml or create a new file:

```yaml
# values-prod.yaml
replicaCount: 3

image:
  tag: "1.25"

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Upgrade Commands

```bash
# Upgrade with default values
helm upgrade myapp ./myapp

# Upgrade with custom values
helm upgrade myapp ./myapp -f values-prod.yaml

# Upgrade with inline values
helm upgrade myapp ./myapp --set replicaCount=5

# Upgrade and reset values to defaults
helm upgrade myapp ./myapp --reset-values
```

### Upgrade Strategy

Helm follows Kubernetes Deployment's update strategy:
- Creates new ReplicaSet
- Gradually scales up new pods
- Scales down old pods
- Maintains availability during rollout

## Rollback

Helm tracks all revisions, making rollback easy:

```bash
# View history
helm history myapp

# Rollback to previous revision
helm rollback myapp

# Rollback to specific revision
helm rollback myapp 2

# Rollback with new values
helm rollback myapp 2 --set replicaCount=1

# Force re-use of values from that revision
helm rollback myapp 2 --reuse-values
```

## Uninstalling

```bash
# Uninstall a release
helm uninstall myapp

# Uninstall but keep history
helm uninstall myapp --keep-history

# Uninstall from specific namespace
helm uninstall myapp -n mynamespace
```

## Your Task: Manage a Release

1. Install your chart:
```bash
cd myapp
helm install myapp ./myapp
```

2. Check the release:
```bash
helm list
helm status myapp
helm get manifest myapp
```

3. Upgrade with more replicas:
```bash
helm upgrade myapp . --set replicaCount=3
```

4. Check history:
```bash
helm history myapp
```

5. Break something and rollback:
```bash
helm upgrade myapp . --set replicaCount=0
kubectl get pods  # Should show no pods
helm rollback myapp
kubectl get pods  # Pods restored
```

6. Uninstall:
```bash
helm uninstall myapp
```

---

## Quick Check

Test your understanding:

1. What's a Helm release? (An instance of a chart deployed to a Kubernetes cluster, tracked by name with revision history)

2. What does `helm install --dry-run` do? (Renders templates and shows what would be created without actually installing to the cluster)

3. How do you upgrade a Helm release? (Use `helm upgrade <release-name> <chart-path>` with optional `-f` for values files or `--set` for inline values)

4. What happens during a Helm rollback? (Reverts the cluster to the state of a previous revision, using the stored manifest from that revision)

5. What's the difference between `helm uninstall` and `helm uninstall --keep-history`? (Regular uninstall removes the release and its history; --keep-history removes resources but preserves revision history)

---

**Continue to `step-03.md`**
