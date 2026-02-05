# Solution: Grafana Dashboards

## Complete Dashboard ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  myapp-dashboard.json: |
    {
      "dashboard": {
        "id": null,
        "title": "My Application",
        "tags": ["kubernetes", "myapp"],
        "timezone": "browser",
        "schemaVersion": 16,
        "version": 1,
        "refresh": "30s",
        "templating": {
          "list": [
            {
              "name": "namespace",
              "type": "query",
              "query": "label_values(kube_pod_info, namespace)",
              "multi": false,
              "includeAll": false,
              "allValue": ""
            },
            {
              "name": "pod",
              "type": "query",
              "query": "label_values(kube_pod_info{namespace=\"$namespace\"}, pod)",
              "multi": true,
              "includeAll": true,
              "allValue": ".*"
            }
          ]
        },
        "panels": [
          {
            "id": 1,
            "title": "Request Rate",
            "type": "graph",
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
            "targets": [
              {
                "expr": "rate(http_requests_total{namespace=\"$namespace\", pod=~\"$pod\"}[5m])",
                "legendFormat": "{{method}} {{status}}"
              }
            ]
          },
          {
            "id": 2,
            "title": "Current QPS",
            "type": "stat",
            "gridPos": {"h": 4, "w": 6, "x": 0, "y": 8},
            "targets": [
              {
                "expr": "sum(rate(http_requests_total{namespace=\"$namespace\", pod=~\"$pod\"}[1m]))"
              }
            ]
          },
          {
            "id": 3,
            "title": "Error Rate",
            "type": "graph",
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 12},
            "targets": [
              {
                "expr": "rate(http_errors_total{namespace=\"$namespace\", pod=~\"$pod\"}[5m])"
              }
            ]
          },
          {
            "id": 4,
            "title": "P95 Latency",
            "type": "graph",
            "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{namespace=\"$namespace\", pod=~\"$pod\"}[5m]))"
              }
            ]
          }
        ]
      }
    }
```

## Accessing Grafana

```bash
# Port-forward
kubectl port-forward svc/kube-prometheus-grafana 3000:80 -n monitoring

# Open browser to http://localhost:3000
# Default: admin / prom-operator

# Or use an ingress
kubectl apply -f ingress.yaml
```
