# Solution: OpenTelemetry Tracing

## Complete Setup

### Jaeger Deployment
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: observability
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector
  namespace: observability
spec:
  ports:
  - port: 14250
    targetPort: 14250
  selector:
    app: jaeger
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: observability
spec:
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686  # UI
        - containerPort: 14250  # Collector gRPC
        - containerPort: 14268  # Collector HTTP
        - containerPort: 9411   # Thrift
```

### OTEL Collector ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-conf
  namespace: observability
data:
  otel-collector.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch:
    exporters:
      jaeger:
        endpoint: jaeger-collector.observability.svc.cluster.local:14250
        tls:
          insecure: true
    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch]
          exporters: [jaeger]
```

### Access Jaeger UI
```bash
kubectl port-forward svc/jaeger-query 16686:16686 -n observability
# Open http://localhost:16686
```

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Trace** | A distributed transaction across services |
| **Span** | A single operation within a trace |
| **Context** | Propagated state linking spans |
| **Sampling** | Selecting which traces to collect |
| **Baggage** | Key-value pairs propagated with context |
