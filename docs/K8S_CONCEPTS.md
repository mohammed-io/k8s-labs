# Kubernetes Concepts - Deep Dive

**Understanding Kubernetes from fundamentals to mastery.**

---

## Table of Contents

1. [Architecture](#1-architecture)
2. [Core Resources](#2-core-resources)
3. [Pod Lifecycle](#3-pod-lifecycle)
4. [Networking Model](#4-networking-model)
5. [Storage](#5-storage)
6. [Configuration](#6-configuration)
7. [Security](#7-security)
8. [Scheduling](#8-scheduling)
9. [Helm & Packaging](#9-helm--packaging)

---

## 1. Architecture

### Control Plane Components

```
                    ┌─────────────────────────────────────┐
                    │          API Server               │
                    │     (kube-apiserver)               │
                    │  Frontend for all K8s operations  │
                    └────────────┬────────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
┌───────▼────────┐    ┌─────────▼────────┐    ┌───────▼────────┐
│   Scheduler    │    │   Controller     │    │  cloud-ctlr    │
│ (kube-scheduler)│    │ (kube-controller)│    │  (node ctrl)   │
│                 │    │    Manager       │    │                │
│ Assign pods to  │    │ Maintains desired │    │ Cloud-specific │
│ nodes           │    │ state            │    │ controllers    │
└─────────────────┘    └──────────────────┘    └────────────────┘
        │                        │                        │
        └────────────────────────┼────────────────────────┘
                                 │
                    ┌────────────▼────────────────────────┐
                    │          etcd                    │
                    │  Distributed key-value store      │
                    │  All cluster data stored here    │
                    └───────────────────────────────────┘
```

### Node Components

```
                    ┌─────────────────────────────────────┐
                    │            Kubelet                  │
                    │    Container runtime interface     │
                    │    (communicates with API server)  │
                    └────────────┬────────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
┌───────▼────────┐    ┌─────────▼────────┐    ┌───────▼────────┐
│  kube-proxy    │    │  Container      │    │  cAdvisor      │
│ Network rules  │    │  Runtime        │    │  Metrics       │
│ (Service VIPs) │    │  (Docker, etc.)  │    │                │
└─────────────────┘    └──────────────────┘    └────────────────┘
```

### Communication Flow

```
┌─────────────┐                  ┌─────────────┐
│    kubectl  │                  │     Pod     │
└──────┬──────┘                  └──────┬──────┘
       │                                  │
       ▼                                  ▼
┌─────────────────┐              ┌─────────────────┐
│  API Server     │◄────────────►│   Kubelet       │
│  (Validates,    │   watch       │   (Executes,    │
│   AuthN/Z,      │               │    restarts)    │
│   Admits)       │              └─────────────────┘
└────────┬────────┘
         │
         ▼
┌─────────────────┐              ┌─────────────────┐
│     etcd        │              │   Scheduler     │
│  (State store)  │◄─────────────│ (Assigns pods) │
└─────────────────┘              └─────────────────┘
```

---

## 2. Core Resources

### Resource Hierarchy

```
Cluster
├── Namespace
│   ├── Pod (smallest deployable unit)
│   │   └── Container (one or more)
│   ├── ReplicaSet (ensures N pods)
│   │   └── Deployment (manages ReplicaSet)
│   ├── StatefulSet (stateful pods)
│   ├── DaemonSet (pod per node)
│   ├── Job (run to completion)
│   └── CronJob (scheduled jobs)
│   ├── Service (network discovery)
│   ├── Ingress (HTTP routing)
│   ├── ConfigMap (configuration)
│   ├── Secret (sensitive data)
│   ├── PersistentVolumeClaim (storage)
│   └── ServiceAccount (identity)
```

### Pod

The smallest deployable unit. A pod encapsulates one or more containers.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: myapp
    env: dev
spec:
  containers:
  - name: main
    image: nginx:alpine
    ports:
    - containerPort: 80
  - name: sidecar
    image: fluent/fluentd
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    emptyDir: {}
```

**Pod States:**
- `Pending` - Cluster accepted, container not created
- `Running` - At least one container running
- `Succeeded` - All containers exited successfully
- `Failed` - At least one container exited with error
- `Unknown` - Can't communicate with pod

### Deployment

Declarative way to manage pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:                # Pod template
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
```

**Deployment Strategy:**
- `RollingUpdate` (default) - Gradually replaces pods
- `Recreate` - Kills all pods, then starts new ones

### Service

Network abstraction for pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web                    # Selects pods with this label
  ports:
  - port: 80                    # Service port
    targetPort: 8080            # Container port
  type: ClusterIP              # Default, cluster-internal
```

**Service Types:**
- `ClusterIP` - Internal only (default)
- `NodePort` - Exposed on each node's IP
- `LoadBalancer` - Cloud load balancer
- `ExternalName` - DNS CNAME record

---

## 3. Pod Lifecycle

### Phases

```
Pending → Running → Succeeded/Failed
   ↓           ↓
Unknown    ContainerCreating
```

### Readiness Probes

Determines if pod is ready to serve traffic.

```yaml
spec:
  containers:
  - name: web
    image: nginx
    readinessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

### Liveness Probes

Determines if container needs restart.

```yaml
spec:
  containers:
  - name: web
    image: nginx
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
```

### Startup Probes

Determines if application has started.

```yaml
spec:
  containers:
  - name: web
    image: nginx
    startupProbe:
      httpGet:
        path: /health
        port: 80
      failureThreshold: 30
```

### Probe Order

```
Startup Probe ─────┐
       ↓              │
   Success?           │
       │              ↓
       Yes         Readiness Probe ──┐
       │              ↓              │
       │           Ready?          ↓
       │              │         Liveness Probe
       └──────────────┴──────────────┘
```

---

## 4. Networking Model

### Pod-to-Pod Communication

```
Pod A (10.244.1.5)          Pod B (10.244.2.7)
┌────────────────┐          ┌────────────────┐
│  Container     │          │  Container     │
│  eth0@pod IP   │          │  eth0@pod IP   │
└────────┬───────┘          └───────┬────────┘
         │                           │
    10.244.1.5                 10.244.2.7
         │                           │
         └─────────┬─────────────────┘
                   │
         ┌──────────▼───────────┐
         │   veth (virtual)      │
         └──────────┬───────────┘
                    │
         ┌──────────▼───────────┐
         │   cbr0 (bridge)       │
         └──────────┬───────────┘
                    │
         ┌──────────▼───────────┐
         │   eth0 (node)        │
         └──────────────────────┘
```

### Service Network Model

```
                ┌────────────────────────────┐
                │      Service (ClusterIP)     │
                │      IP: 10.96.0.10         │
                └──────────┬─────────────────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
      ┌─────▼─────┐ ┌────▼────┐ ┌────▼─────┐
      │   Pod 1   │ │  Pod 2  │ │  Pod 3   │
      │ 10.244.1.5│ │10.244.2.5│ │10.244.3.5│
      └───────────┘ └──────────┘ └──────────┘
```

### Ingress

```
Internet
    │
    ▼
┌─────────────┐
│   Ingress   │
│  Controller │
└─────┬───────┘
      │
      ▼
┌────────────────────┐
│   Ingress Resource │
│  (routing rules)   │
└─────┬──────────────┘
      │
      ▼
┌────────────────────┐
│     Services       │
│  (cluster.local)   │
└────────────────────┘
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

---

## 5. Storage

### PV vs PVC

```
┌─────────────────┐        ┌─────────────────┐
│  PersistentVolume│◄──────►│ PersistentVolume │
│    (PV)         │        │     Claim        │
│  Cluster resource│        │   (PVC)          │
│                 │        │  Namespace-scoped│
└─────────────────┘        └────────┬────────┘
                                   │
                                   ▼
                            ┌─────────────────┐
                            │      Pod         │
                            └─────────────────┘
```

### Storage Classes

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### StatefulSet

For stateful applications (databases).

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: standard
      resources:
        requests:
          storage: 10Gi
```

---

## 6. Configuration

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.url: "postgres://localhost:5432/mydb"
  cache.ttl: "3600"
  feature.enabled: "true"
---
# Usage in pod
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    envFrom:
    - configMapRef:
        name: app-config
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=  # base64 encoded
---
# Usage
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
```

### Secret Types

| Type | Usage |
|------|-------|
| `Opaque` | Arbitrary user data |
| `kubernetes.io/service-account-token` | Service account token |
| `kubernetes.io/dockercfg` | Docker config |
| `kubernetes.io/tls` | TLS certificate |
| `kubernetes.io/sshauth` | SSH auth |

---

## 7. Security

### RBAC (Role-Based Access Control)

```
┌────────────────────────────────────────┐
│              Subject                   │
│  (User, Group, or ServiceAccount)     │
└──────────────┬─────────────────────────┘
               │
               ▼
┌────────────────────────────────────────┐
│              Role                     │
│         (rules + permissions)         │
│  (defines what CAN be done)           │
└──────────────┬─────────────────────────┘
               │
               ▼
┌────────────────────────────────────────┐
│            RoleBinding                │
│       (binds role to subject)          │
│  (defines WHO can do WHAT)             │
└──────────────┬─────────────────────────┘
               │
               ▼
┌────────────────────────────────────────┐
│              Namespace                 │
│         (scope of permissions)         │
└────────────────────────────────────────┘
```

### Pod Security Standards

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secured-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
      add:
      - NET_BIND_SERVICE
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
```

---

## 8. Scheduling

### Taints and Tolerations

```bash
# Taint a node (repel pods without toleration)
kubectl taint nodes node1 key=value:NoSchedule

# Remove taint
kubectl taint nodes node1 key:NoSchedule-
```

```yaml
# Pod with toleration
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

### Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: zone
              operator: In
              values:
              - us-west-1
```

### Pod Affinity/Anti-Affinity

```yaml
spec:
  affinity:
    # Pod affinity: colocate with certain pods
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web
        topologyKey: kubernetes.io/hostname
    # Pod anti-affinity: spread out
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - api
          topologyKey: kubernetes.io/hostname
```

---

## 9. Helm & Packaging

### Helm Chart Structure

```
my-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── values.schema.json       # Values schema
├── templates/               # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── _helpers.tpl         # Template helpers
│   └── NOTES.txt            # Post-install notes
└── charts/                  # Dependency charts
```

### Chart.yaml

```yaml
apiVersion: v2
name: my-chart
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - kubernetes
  - application
maintainers:
  - name: Your Name
    email: you@example.com
```

### Template Functions

```yaml
# Values injection
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"

# Conditional
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
{{- end }}

# Loops
{{- range .Values.environments }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-{{ . }}
{{- end }}

# Named templates (helpers)
{{- define "labels" -}}
app: {{ .Values.app.name }}
version: {{ .Values.app.version }}
{{- end }}

# Use named template
metadata:
  labels:
    {{- include "labels" . | nindent 4 }}
```

### Value Files

```yaml
# values.yaml
image:
  repository: nginx
  tag: "1.25"
service:
  type: ClusterIP
  port: 80

# prod-values.yaml
image:
  tag: "1.25"
service:
  type: LoadBalancer
  port: 80
replicas: 5
```

```bash
# Install with custom values
helm install my-release ./my-chart -f prod-values.yaml
```

---

## Key Concepts Summary

| Concept | Description | Why It Matters |
|----------|-------------|----------------|
| **Pod** | Smallest deployable unit | Basic building block |
| **Deployment** | Declarative pod management | Rolling updates, rollbacks |
| **Service** | Network discovery | Stable endpoint for pods |
| **ConfigMap** | Configuration data | Separate config from code |
| **Secret** | Sensitive data | Secure credential management |
| **Namespace** | Resource isolation | Multi-tenancy |
| **Ingress** | HTTP routing | External access |
| **PV/PVC** | Storage abstraction | Stateful workloads |
| **RBAC** | Authorization | Security |
| **Helm** | Package manager | Reusable deployments |

---

**Next:** See `docs/MONITORING_CONCEPTS.md` for Prometheus, Grafana, and OpenTelemetry.
