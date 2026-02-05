# Step 1: Creating Dashboards

---

## Dashboard Provisioning

Store dashboards as ConfigMaps for version control:

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
        "title": "My Application",
        "tags": ["kubernetes", "myapp"],
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])",
                "legendFormat": "{{method}} {{status}}"
              }
            ]
          }
        ],
        "refresh": "30s"
      }
    }
```

## Panel Types

| Type | Use Case |
|------|----------|
| **Graph** | Time-series metrics |
| **Stat** | Single values |
| **Table** | Tabular data |
| **Heatmap** | Distribution visualization |
| **Gauge** | Single value with range |
| **Logs** | Log viewing (with Loki) |

## Dashboard Variables

Make dashboards interactive with variables:

```json
{
  "templating": {
    "list": [
      {
        "name": "namespace",
        "type": "query",
        "query": "label_values(kube_pod_info, namespace)",
        "multi": false
      },
      {
        "name": "pod",
        "type": "query",
        "query": "label_values(kube_pod_info{namespace=\"$namespace\"}, pod)",
        "multi": true
      }
    ]
  }
}
```

Use variables in queries: `rate(http_requests_total{namespace="$namespace", pod=~"$pod"}[5m])`

## Your Task: Create a Dashboard

1. Create a ConfigMap with your dashboard JSON
2. Include panels for:
   - Request rate (graph)
   - Error rate (graph)
   - P95 latency (graph)
   - Current QPS (stat)
3. Add variables for namespace and pod filtering
4. Apply and verify in Grafana

---

## Quick Check

1. What's dashboard provisioning? (Storing dashboard definitions in ConfigMaps (or files) that Grafana auto-loads, enabling version control)

2. How do variables work in Grafana? (They allow dynamic filtering of dashboard content, populated from queries, datasources, or custom values)

3. What's the difference between graph and stat panels? (Graph shows time-series data over time; stat shows a single current value)

4. How do you provision dashboards in Kubernetes? (Create ConfigMaps with dashboard JSON and add the label `grafana_dashboard: "1"`)

5. Why use dashboard-as-code? (Enables version control, automated deployment, consistent dashboards across environments, and peer review)

---

**Continue to `solution.md`**
