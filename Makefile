# Kubernetes & Monitoring Lab - Makefile
# Convenience targets for common operations

.PHONY: help setup install-prometheus clean health-check all demo install run

# Default target
help:
	@echo "Kubernetes & Monitoring Lab"
	@echo ""
	@echo "Available targets:"
	@echo "  make install        - Install dependencies with uv"
	@echo "  make run            - Run Streamlit app"
	@echo "  make setup          - Create kind cluster"
	@echo "  make health-check    - Verify environment"
	@echo "  make install-prometheus - Install monitoring stack"
	@echo "  make demo           - Deploy all demo apps"
	@echo "  make clean          - Remove all resources"
	@echo "  make status         - Show cluster status"
	@echo ""
	@echo "Scenario shortcuts - Basics:"
	@echo "  make s01            - Deploy scenario 01 (k8s-basics)"
	@echo "  make s02            - Deploy scenario 02 (config-secrets)"
	@echo "  make s03            - Deploy scenario 03 (networking)"
	@echo "  make s04            - Deploy scenario 04 (storage)"
	@echo "  make s05            - Deploy scenario 05 (helm-charts)"
	@echo ""
	@echo "Scenario shortcuts - Intermediate:"
	@echo "  make s06            - Deploy scenario 06 (self-healing)"
	@echo "  make s07            - Deploy scenario 07 (monitoring-basics)"
	@echo "  make s08            - Deploy scenario 08 (grafana-dashboards)"
	@echo "  make s09            - Deploy scenario 09 (opentelemetry)"
	@echo ""
	@echo "Scenario shortcuts - Advanced:"
	@echo "  make s10            - Deploy scenario 10 (production-ready)"
	@echo ""

install:
	uv sync

run:
	uv run streamlit run main.py

# Setup: Create cluster
setup:
	@echo "Creating kind cluster..."
	@./scripts/create-cluster.sh

# Install Prometheus stack
install-prometheus:
	@echo "Installing Prometheus stack..."
	@./scripts/install-prometheus.sh

# Health check
health-check:
	@./scripts/health-check.sh

# Clean everything
clean:
	@./scripts/cleanup.sh

# Status check
status:
	@echo "Cluster Info:"
	@kubectl cluster-info
	@echo ""
	@echo "Nodes:"
	@kubectl get nodes
	@echo ""
	@echo "All Pods:"
	@kubectl get pods -A

# Deploy self-healing demo apps
demo:
	@echo "Demo apps not yet available in new structure"
	@echo "Check learning-materials/intermediate/06-self-healing/"

# Scenario shortcuts - Basics
s01:
	@echo "Deploying Scenario 01 (k8s-basics)..."
	@kubectl apply -f learning-materials/basics/01-k8s-basics/lab/manifests/
	@echo "Scenario 01 deployed!"

s02:
	@echo "Deploying Scenario 02 (config-secrets)..."
	@kubectl apply -f learning-materials/basics/02-config-secrets/lab/manifests/
	@echo "Scenario 02 deployed!"

s03:
	@echo "Deploying Scenario 03 (networking)..."
	@kubectl apply -f learning-materials/basics/03-networking/lab/manifests/
	@echo "Scenario 03 deployed!"

s04:
	@echo "Deploying Scenario 04 (storage)..."
	@kubectl apply -f learning-materials/basics/04-storage/lab/manifests/
	@echo "Scenario 04 deployed!"

s05:
	@echo "Deploying Scenario 05 (helm-charts)..."
	@echo "Helm deployment - check learning-materials/basics/05-helm-charts/"
	@# @helm install myapp learning-materials/basics/05-helm-charts --values learning-materials/basics/05-helm-charts/values-dev.yaml
	@echo "Scenario 05 deployed!"

# Scenario shortcuts - Intermediate
s06:
	@echo "Deploying Scenario 06 (self-healing)..."
	@kubectl apply -f learning-materials/intermediate/06-self-healing/lab/manifests/
	@echo "Scenario 06 deployed!"

s07:
	@echo "Scenario 07 (monitoring-basics) requires Prometheus - run make install-prometheus first"
	@kubectl apply -f learning-materials/intermediate/07-monitoring-basics/lab/manifests/

s08:
	@echo "Scenario 08 (grafana-dashboards) requires Grafana - run make install-prometheus first"
	@echo "Access dashboards at: http://localhost:3000"
	@kubectl apply -f learning-materials/intermediate/08-grafana-dashboards/lab/manifests/

s09:
	@echo "Deploying Scenario 09 (opentelemetry)..."
	@kubectl apply -f learning-materials/intermediate/09-opentelemetry/lab/manifests/

# Scenario shortcuts - Advanced
s10:
	@echo "Scenario 10 (production-ready) requires monitoring stack - run make install-prometheus first"
	@kubectl apply -f learning-materials/advanced/10-production-ready/lab/manifests/

# Port forwarding shortcuts
pf-prometheus:
	@echo "Forwarding Prometheus to localhost:9090..."
	@kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090

pf-grafana:
	@echo "Forwarding Grafana to localhost:3000..."
	@kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

pf-jaeger:
	@echo "Forwarding Jaeger to localhost:16686..."
	@kubectl port-forward -n tracing svc/jaeger-query 16686:16686
