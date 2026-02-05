---
name: "Helm Charts"
category: "basics"
difficulty: "intermediate"
time: "50 minutes"
concepts: ["helm", "chart", "template", "release"]
tools: ["kubectl", "helm", "minikube"]
---

# Helm Charts

Learn how to package, configure, and deploy applications with Helm.

## The Problem

You've been creating individual YAML files for each deployment. Now you need to:
1. Package your application for reuse across environments
2. Support multiple configurations (dev, staging, prod)
3. Make deployments repeatable and versioned
4. Enable easy upgrades and rollbacks

Helm is the package manager for Kubernetes that solves these problems.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Helm Architecture                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────┐                                        │
│  │   Helm     │  Client (helm CLI)                     │
│  │   Client   │                                        │
│  └─────┬──────┘                                        │
│        │                                               │
│        │ helm install/upgrade/uninstall                 │
│        │                                               │
│        ▼                                               │
│  ┌─────────────────────────────────────────┐            │
│  │         Kubernetes API Server           │            │
│  │                                         │            │
│  │  ┌─────────────────────────────────┐   │            │
│  │  │        Release (installed chart)  │   │            │
│  │  │                                 │   │            │
│  │  │  Chart Name: myapp              │   │            │
│  │  │  Namespace: default             │   │            │
│  │  │  Revision: 1                    │   │            │
│  │  │  Status: deployed               │   │            │
│  │  └─────────────────────────────────┘   │            │
│  └─────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────┘
```

## Requirements

1. **Helm Chart**: Create a packaged chart with templates
2. **Templates**: Use Helm templating to generate Kubernetes manifests
3. **Values Files**: Support environment-specific configurations
4. **Release Management**: Install, upgrade, and rollback releases

## Constraints

- Helm 3 (no Tiller server component)
- Chart structure must follow Helm conventions
- Templates must be valid Go template syntax

## Prerequisites

- ✅ Scenario 01: Kubernetes Basics (Pods, Deployments, Services)
- ✅ Scenario 02: ConfigMaps and Secrets
- ✅ Understanding of YAML structure
- Helm 3 installed

## What You'll Learn

| Concept | Why It Matters |
|---------|----------------|
| **Charts** | Reusable application packages |
| **Templates** | Dynamic manifest generation |
| **Values** | Environment-specific configuration |
| **Releases** | Versioned deployments with rollback |

## Getting Started

```bash
# Verify Helm is installed
helm version

# Create a chart to explore
helm create myapp
cd myapp
ls -la
```

## Verification

After completing this scenario, you should be able to:
- Create a Helm chart from scratch
- Use Helm templating to generate manifests
- Install and manage Helm releases
- Handle environment-specific configurations
- Perform upgrades and rollbacks

---

**Start with `step-01.md`**
