# Step 1: OpenTelemetry Setup

---

## OpenTelemetry Components

| Component | Purpose |
|-----------|---------|
| **SDK** | Instruments your application |
| **Collector** | Processes and exports telemetry |
| **Jaeger** | Stores and visualizes traces |

## Automatic Instrumentation

For Go, Java, Python, Node.js, .NET:

```bash
# Java with auto-instrumentation
java -javaagent:opentelemetry-javaagent.jar \
     -Dotel.service.name=myapp \
     -Dotel.exporter=otlp \
     -jar myapp.jar
```

## Manual Instrumentation (Go)

```go
import "go.opentelemetry.io/otel"
import "go.opentelemetry.io/otel/trace"

tracer := otel.Tracer("myapp")

ctx, span := tracer.Start(ctx, "operation-name")
defer span.End()

// Add attributes
span.SetAttributes(
    attribute.String("http.method", r.Method),
    attribute.String("http.url", r.URL.String()),
)

// Create child spans
ctx, childSpan := tracer.Start(ctx, "child-operation")
defer childSpan.End()
```

## OTEL Collector Config

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:

exporters:
  jaeger:
    endpoint: jaeger-collector.observability.svc:14250
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger]
```

## Trace Propagation

Context is propagated via HTTP headers:

| Header | Purpose |
|--------|---------|
| `traceparent` | Trace ID, span ID, sampled flag |
| `tracestate` | Vendor-specific data |

Services must forward these headers in downstream calls.

---

## Quick Check

1. What's a trace in OpenTelemetry? (A collection of spans representing the path of a request through a distributed system)

2. What's the relationship between traces and spans? (A trace is a tree of spans, where each span represents a single operation and child spans represent sub-operations)

3. What does the OTEL Collector do? (Receives, processes, and exports telemetry data to various backends, acting as a central pipeline)

4. How is trace context propagated between services? (Via HTTP headers like `traceparent` that contain the trace ID, span ID, and sampling flag)

5. What's Jaeger's role? (Stores trace data and provides a UI for visualizing and analyzing traces)

---

**Continue to `solution.md`**
