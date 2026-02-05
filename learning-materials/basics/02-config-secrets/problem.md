---
name: "Configuration & Secrets"
category: "basics"
difficulty: "beginner"
time: "30 minutes"
concepts: ["configmap", "secret", "environment-variables", "volume-mounts"]
---

# Configuration & Secrets

## Scenario

Your application needs configuration - some non-sensitive (database host, cache TTL) and some sensitive (passwords, API keys). You'll learn to properly separate these concerns in Kubernetes.

## Architecture

```
┌─────────────────────────────────────────┐
│          Kubernetes Pod                 │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │   Container                      │   │
│  │                                  │   │
│  │  Environment Variables:          │   │
│  │  • DB_HOST=postgres.example.com  │   │
│  │  • API_KEY=******** (Secret)     │   │
│  │                                  │   │
│  │  Mounted Files:                  │   │
│  │  /etc/config/app.yaml (ConfigMap) │   │
│  │  /etc/secrets/tls.key (Secret)    │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## Requirements

Build configuration management for an application:

1. **ConfigMap** for non-sensitive configuration:
   - Database host, port, cache settings
   - Feature flags
   - Log level

2. **Secret** for sensitive data:
   - Database password
   - API keys

3. **Pod** that uses both:
   - Inject some values as environment variables
   - Mount some as files

## Constraints

- Never put passwords in ConfigMaps
- Use Secrets for sensitive data only
- Test both environment variable and volume mount approaches

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `db_host` | postgres.example.com | Database host |
| `db_port` | 5432 | Database port |
| `cache_ttl` | 3600 | Cache TTL in seconds |

## Prerequisites

- ✅ Scenario 01: Kubernetes Basics
- kubectl installed and configured
- Running Kubernetes cluster

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **ConfigMap** | Store non-sensitive configuration separately from code |
| **Secret** | Store sensitive data with access control |
| **Environment Variables** | Runtime configuration for containers |
| **Volume Mounts** | Mount configuration as files in containers |

## Getting Started

```bash
cd learning-materials/basics/02-config-secrets/lab
kubectl apply -f .
```

## Verification

```bash
# Check ConfigMap
kubectl get configmap app-config

# Check Secret
kubectl get secret app-secret

# Check pod can access config
kubectl exec -it config-demo -- env | grep DB_HOST
```
