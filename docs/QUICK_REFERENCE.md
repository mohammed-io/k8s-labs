# Kubernetes & Monitoring - Quick Reference

**Daily commands for K8s, Prometheus, Grafana, and OpenTelemetry.**

---

## kubectl Commands

```bash
# Cluster Info
kubectl cluster-info                    # Cluster endpoints
kubectl version                         # Client and server version
kubectl api-resources                    # All API resources
kubectl api-resources | grep -i pod      # Search resources

# Nodes
kubectl get nodes                         # List nodes
kubectl describe node <name>              # Node details
kubectl top nodes                         # Resource usage
kubectl cordon <node>                    # Mark unschedulable
kubectl uncordon <node>                  # Mark schedulable
kubectl drain <node>                     # Evict all pods

# Namespaces
kubectl get ns                           # List namespaces
kubectl create ns <name>                 # Create namespace
kubectl config set-context --current namespace=<name>  # Set default

# Pods
kubectl get pods -A                      # All pods, all namespaces
kubectl get pods -l app=web              # Pods with label
kubectl describe pod <name>              # Full details
kubectl logs <pod>                       # Logs
kubectl logs -f <pod>                    # Follow logs
kubectl logs <pod> --previous            # Previous container
kubectl exec -it <pod> -- sh            # Shell into pod
kubectl delete pod <name>                # Delete pod
kubectl port-forward <pod> 8080:80       # Port forward

# Deployments
kubectl get deployments                  # List deployments
kubectl describe deployment <name>       # Full details
kubectl rollout restart deployment/<name>  # Restart
kubectl rollout status deployment/<name>    # Check rollout
kubectl rollout undo deployment/<name>      # Undo rollout
kubectl scale deployment/<name> --replicas=3  # Scale
kubectl autoscale deployment/<name> --min=2 --max=5  # Autoscale

# Services
kubectl get svc                          # List services
kubectl describe svc <name>               # Service details
kubectl get endpoints <name>             # Endpoints for service

# ConfigMaps & Secrets
kubectl get configmaps
kubectl describe configmap <name>
kubectl get secrets
kubectl describe secret <name>
kubectl create secret generic <name> --from-literal=key=value
kubectl create secret tls <name> --cert=path.crt --key=path.key

# Apply & Delete
kubectl apply -f manifest.yaml            # Apply configuration
kubectl delete -f manifest.yaml           # Delete from file
kubectl apply -f dir/                    # Apply all in directory
kubectl delete -f dir/

# Events & Troubleshooting
kubectl get events -A                     # All events
kubectl describe pod <pod>               # Check pod issues
kubectl logs <pod> --all-containers=true  # All container logs
kubectl top pods -A                       # Resource usage
kubectl get pods -o wide                 # With node info

# Edit in place
kubectl edit pod <name>                  # Edit pod config
kubectl edit svc <name>                  # Edit service
kubectl edit configmap <name>            # Edit configmap

# Exports
kubectl get pod <pod> -o yaml            # Export YAML
kubectl get all -o yaml                  # Export everything
kubectl get all -o json                  # Export JSON
```

---

## Helm Commands

```bash
# Version
helm version

# Repositories
helm repo add <name> <url>              # Add repo
helm repo update                        # Update repos
helm repo list                          # List repos
helm search <keyword>                   # Search charts

# Install
helm install <release> <chart>          # Install chart
helm install <release> <chart> -n <ns>   # In namespace
helm install <release> <chart> --set key=value  # With values
helm install <release> <chart> -f values.yaml  # From file

# Upgrade
helm upgrade <release> <chart>          # Upgrade
helm upgrade <release> <chart> --reuse-values  # Keep existing values

# Status
helm status <release>                   # Release status
helm list                               # List releases
helm list -A                            # All namespaces
helm history <release>                  # Release history

# Uninstall
helm uninstall <release>                # Delete release
helm uninstall <release> --keep-history  # Keep history

# Values
helm show values <chart>                # Show default values
helm get values <release>               # Get current values
helm get values <release> -o yaml       # YAML format

# Pull/Template
helm pull <chart>                       # Download chart
helm template <release> <chart>         # Render templates (don't install)
helm dependency list <chart>           # List dependencies
helm dependency update <chart>          # Update dependencies
```

---

## Prometheus Queries (PromQL)

```bash
# Basic queries
up                                      # All targets that are up
http_requests_total                     # Total HTTP requests
rate(http_requests_total[5m])          # Per-second rate over 5m
irate(http_requests_total[5m])         # Per-second rate (for counters)

# Label filtering
http_requests_total{job="api"}          # By label
http_requests_total{job=~"api.*"}      # Regex match
http_requests_total{job!~"test.*"}     # Negative match

# Aggregation
sum(http_requests_total)               # Sum across all labels
sum by (job) (http_requests_total)      # Sum by job
avg(http_requests_total)               # Average
max(http_requests_total)               # Maximum
min(http_requests_total)               # Minimum
count(http_requests_total)              # Count series

# Time-based
rate(http_requests_total[5m])          # Rate over 5m
rate(http_requests_total[1h])          # Rate over 1h
increase(http_requests_total[1h])      # Increase over 1h

# Percentiles
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Offset
http_requests_total offset 1h          # Data from 1 hour ago

# Comparison
http_requests_total > 100              # Greater than
http_requests_total == 0               # Equals
```

---

## Grafana Queries

```sql
-- Loki (Logs)
{app="myapp", env="prod"} |= "error"
{namespace="default"} |~ "error.*timeout"
{job="varlogs"} |= "error" | line_format "{{.timestamp}} {{.message}}"

-- Tempo (Traces)
{service.name="api"}
{service.name="api", span.name="handler"}
{http.status_code >= 400}
```

---

## Common Label Selectors

```bash
# Equality
app=web                                  # Exact match
environment!=prod                         # Not equal

# Set membership
environment in (dev, staging)             # In set
environment notin (prod, dr)               # Not in set

# Regex
app=~".*-service"                         # Regex match
app!~".*-test"                            # Negative regex

# Existence
app                                        # Exists (not null)
!app                                       # Does not exist

# Multiple conditions
app=web,env=prod                           # AND (comma)
app in (web,api),env!=prod                 # AND
```

---

## Port Forwarding

```bash
# Local service
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000

# Pod
kubectl port-forward pod/prometheus-xxx 9090:9090

# Random local port
kubectl port-forward svc/prometheus :9090
```

---

## Common Troubleshooting

```bash
# Pod not starting
kubectl describe pod <pod>               # Check events
kubectl logs <pod>                        # Check logs
kubectl get events -A --field-selector involvedObject.name=<pod>

# CrashLoopBackOff
kubectl logs <pod> --previous            # Previous container logs
kubectl describe pod <pod>               # Exit code

# ImagePullBackOff
kubectl describe pod <pod>               # Image details
kubectl get pods -o jsonpath='{range .items[*]}{.status.containerStatuses[*].imageID}{"\n"}{end}'

# Service not working
kubectl get endpoints <service>          # Check endpoints
kubectl describe pod <pod> -l app=<name> # Check pod labels

# Node issues
kubectl describe node <node>             # Node conditions
kubectl get pods -o wide                  # See pod distribution
```

---

## Common Metrics to Query

```promql
# Cluster
up{job="kube-state-metrics"}             # K8s metrics working
kube_node_info                           # Node info
kube_pod_info                             # Pod info
kube_deployment_status_replicas         # Deployment replicas

# Application
http_requests_total{job="myapp"}         # Total requests
rate(http_requests_total{job="myapp"}[5m])  # Request rate
http_request_duration_seconds{job="myapp"}  # Latency histogram

# RED Method
rate(requests_total[5m])                 # Rate
rate(errors_total[5m])                   # Errors
rate(request_duration_seconds_sum[5m]) / rate(request_duration_seconds_count[5m])  # Duration

# Resource Usage
rate(container_cpu_usage_seconds_total{namespace="default"}[5m])
container_memory_working_set_bytes{namespace="default"}

# Kubernetes Health
kube_pod_status_phase{namespace="default", phase!="Running"}
kube_pod_container_status_restarts_total{namespace="default"} > 0
```

---

## Quick YAML Templates

```yaml
# Pod
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: nginx:alpine
    ports:
    - containerPort: 80

# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: nginx:alpine
        ports:
        - containerPort: 80

# Service
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80

# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  key: value
```

---

**See individual scenario READMEs for detailed learning.**
