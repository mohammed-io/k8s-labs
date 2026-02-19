---
name: "OpenTelemetry Tracing"
category: "intermediate"
difficulty: "advanced"
time: "50 minutes"
concepts: ["opentelemetry", "tracing", "otel-collector", "jaeger"]
tools: ["kubectl", "helm", "opentelemetry"]
---

# OpenTelemetry Tracing

Learn distributed tracing with OpenTelemetry and Jaeger.

## Scenario

Microservices architectures create complex request flows:
- A single user request spans multiple services
- Debugging issues requires tracing the entire flow
- Performance optimization needs end-to-end visibility

## Architecture

```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Service │    │ Service │    │ Service │
│    A    │───▶│    B    │───▶│    C    │
└────┬────┘    └────┬────┘    └────┬────┘
     │              │              │
     └──────────────┴──────────────┘
                    │
                    ▼
            ┌───────────────┐
            │ OTEL Collector│
            │   (Batching,  │
            │   Processing) │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │    Jaeger     │
            │   (Traces)    │
            └───────────────┘
```

## Requirements

1. **OpenTelemetry**: Install SDKs in your applications
2. **OTel Collector**: Central telemetry processing
3. **Jaeger**: Trace visualization backend
4. **Propagation**: Context headers across services

## Constraints

- Use OTLP as the primary ingestion path to the collector
- Keep collector config explicit (receivers, processors, exporters)
- Validate trace flow end-to-end from app to backend

## Prerequisites

- Kubernetes cluster with observability namespace access
- Basic understanding of microservice request flow
- Helm and kubectl installed

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **Trace/Span Model** | Helps isolate latency and failure hotspots |
| **Context Propagation** | Preserves request lineage across services |
| **Collector Pipelines** | Enables centralized telemetry processing |
| **Backend Visualization** | Turns trace data into actionable debugging workflows |

## Getting Started

```bash
# Install Jaeger
helm install jaeger jaegertracing/jaeger -n observability --create-namespace

# Install OTEL Collector
helm install opentelemetry-operator open-telemetry/opentelemetry-operator -n observability
```

## Verification

```bash
kubectl get deployment otel-collector -n observability
kubectl get configmap otel-collector-conf -n observability
kubectl get deployment jaeger -n observability
```

---

**Start with `step-01.md`**
