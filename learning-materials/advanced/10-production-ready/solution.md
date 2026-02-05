# Solution: Production-Ready Kubernetes

## Complete Manifests

### Resource Quota
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

### Limit Range
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

### Network Policy (Default Deny)
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
```

### Alertmanager Config
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yaml: |
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'cluster']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'default'
      routes:
      - match:
          severity: critical
        receiver: 'pagerduty'
      - match:
          severity: warning
        receiver: 'slack'
    receivers:
    - name: 'pagerduty'
      pagerduty_configs:
      - service_key: '<service-key>'
    - name: 'slack'
      slack_configs:
      - api_url: '<slack-webhook-url>'
```

## Production Checklist

| Area | Checklist Items |
|------|----------------|
| **Monitoring** | ✓ Prometheus + Grafana<br>✓ SLOs defined<br>✓ Recording rules |
| **Alerting** | ✓ Alert routes configured<br>✓ On-call rotation<br>✓ Runbooks documented |
| **Security** | ✓ Network policies<br>✓ RBAC configured<br>✓ Secrets encrypted |
| **Resources** | ✓ Resource quotas<br>✓ Limit ranges<br>✓ HPA configured |
| **Backup** | ✓ etcd backups<br>✓ Application backups<br>✓ Tested restores |
| **DR** | ✓ RPO/RTO defined<br>✓ Multi-region (if needed)<br>✓ DR drills practiced |
