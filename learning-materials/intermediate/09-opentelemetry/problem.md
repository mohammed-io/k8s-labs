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

## The Problem

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

## Getting Started

```bash
# Install Jaeger
helm install jaeger jaegertracing/jaeger -n observability --create-namespace

# Install OTEL Collector
helm install opentelemetry-operator open-telemetry/opentelemetry-operator -n observability
```

---

**Start with `step-01.md`**
