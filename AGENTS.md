# AGENTS.md

This file defines the structure and conventions for adding new scenarios to the k8s-monitoring-lab.

---

## Directory Structure

```
k8s-monitoring-lab/
├── learning-materials/
│   ├── basics/
│   │   ├── 01-k8s-basics/
│   │   ├── 02-config-secrets/
│   │   ├── 03-networking/
│   │   ├── 04-storage/
│   │   └── 05-helm-charts/
│   ├── intermediate/
│   │   ├── 06-self-healing/
│   │   ├── 07-monitoring-basics/
│   │   ├── 08-grafana-dashboards/
│   │   └── 09-opentelemetry/
│   └── advanced/
│       └── 10-production-ready/
└── each-scenario-directory/
    ├── problem.md          # Required: Scenario overview
    ├── step-01.md          # Guided hints
    ├── step-02.md
    ├── solution.md         # Required: Complete solution
    └── lab/                # Required: Hands-on workspace
        ├── README.md       # Setup instructions
        ├── manifests/      # Kubernetes manifest files
        └── verify.sh       # Automated verification
```

---

## Frontmatter Fields

| Field | Required | Values |
|-------|----------|--------|
| `name` | Yes | string |
| `category` | Yes | basics, intermediate, advanced |
| `difficulty` | Yes | beginner, intermediate, advanced |
| `time` | Yes | "XX minutes" |
| `concepts` | No | [K8s concept names] |
| `tools` | No | [Tool names like kubectl, helm, minikube] |

---

## problem.md (Required)

```yaml
---
name: "Kubernetes Basics"
category: "basics"
difficulty: "beginner"
time: "20 minutes"
concepts: ["pod", "deployment", "service"]
tools: ["kubectl", "minikube"]
---

# Scenario Title

**Brief description**

## Scenario

Real-world context for this Kubernetes scenario.

## Architecture

ASCII diagram showing components.

## Requirements

Numbered list of resources to create.

## Constraints

Limitations or specific approaches required.

## Prerequisites

Skills and tools needed (kubectl, minikube, kind, etc.).

## What You'll Learn

Table of concepts and why they matter.

## Getting Started

Cluster setup commands.

## Verification

How to verify the solution.
```

### Required Sections

Every `problem.md` MUST include:

1. **Scenario** - A realistic context (who, what, why)
2. **Architecture** - ASCII diagram of components
3. **Requirements** - Numbered list of resources
4. **Constraints** - Limitations or specific approaches
5. **Prerequisites** - Skills and tools needed
6. **What You'll Learn** - Table of concepts
7. **Getting Started** - Cluster setup commands
8. **Verification** - How to verify the solution

---

## step-*.md (Optional)

```markdown
# Step N: Title

**Concept explanation**

## [Resource Type]

Detailed explanation with YAML examples.

## Your Task

Specific implementation tasks.

## Quick Check

5 questions with parenthetical answers.
```

### Quick Check Format

Each step must have exactly 5 questions:

```markdown
## Quick Check

Test your understanding:

1. What's a Kubernetes Pod? (The smallest deployable unit in Kubernetes, containing one or more containers)

2. What does kubectl apply do? (Applies a configuration to a resource by filename or stdin)

3. What's the difference between Deployment and StatefulSet? (Deployments are stateless, StatefulSets maintain sticky identity for each pod)
...
```

---

## solution.md (Required)

```markdown
# Solution: Scenario Name

## Complete manifests

Full working Kubernetes YAML configurations.

## Explanation

What each resource does and why.

## Testing

Commands to verify and test.

## Key Concepts Demonstrated

Summary table.
```

### Requirements

The solution is a reference, not the only path. It MUST:

1. Include **baseline checks** before making changes
2. Explain **why** each step is needed (not just commands)
3. Include **verification steps** after each major change
4. Include **cleanup/reset instructions** for re-running the lab

---

## lab/ (Required)

```
lab/
├── README.md       # Setup, cluster commands
├── manifests/      # Starter YAML with TODO/HINT comments
└── verify.sh       # Automated verification
```

### manifests/*.yaml

```yaml
# TODO: Create a Deployment with 3 replicas
# HINT: Use spec.replicas: 3

# TODO: Add a liveness probe
# HINT: Use livenessProbe with httpGet on /health
```

### verify.sh

```bash
#!/bin/bash
set -e

echo "=== Verification ==="

# Check if cluster is running
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Cluster not running"
    exit 1
fi

# Check if resources exist
# ... specific kubectl checks ...

echo "=== All checks passed ==="
```

---

## Naming Conventions

- **Scenarios**: `NN-scenario-name` (2-digit number, kebab-case)
- **Files**: lowercase, kebab-case for multi-word

---

## Adding New Scenarios

1. **Create scenario directory** in appropriate category under `learning-materials/`
2. **Write problem.md** with complete frontmatter
3. **Create step-*.md files** (1-2 steps typical)
4. **Write solution.md** with complete YAML
5. **Create lab/** with:
   - README.md (setup including cluster commands)
   - manifests/ (TODO/HINT format YAML files)
   - verify.sh (executable)
6. **Restart Streamlit app** to include new scenario

---

## Cluster Setup

For local development, recommend one of:

```bash
# Minikube
minikube start --cpus=4 --memory=8192

# Kind
kind create cluster --name k8s-lab

# k3d
k3d cluster create k8s-lab
```

---

## Testing New Scenarios

1. Start your local cluster
2. Follow your own step-by-step guidance
3. Verify with `kubectl get all`
4. Run verify.sh script
5. Test cleanup with `kubectl delete -f manifests/`

---

## What NOT To Do

- ❌ Skip Quick Check sections
- ❌ Create scenarios without practical K8s patterns
- ❌ Use hardcoded values without explaining
- ❌ Skip HINT comments in lab files
- ❌ Create verify.sh that doesn't actually verify
