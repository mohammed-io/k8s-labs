# Kubernetes & Monitoring Lab - Makefile
# Convenience targets for common operations

.PHONY: help setup install-prometheus clean health-check all demo

# Default target
help:
	@echo "Kubernetes & Monitoring Lab"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup          - Create kind cluster"
	@echo "  make health-check    - Verify environment"
	@echo "  make install-prometheus - Install monitoring stack"
	@echo "  make demo           - Deploy all demo apps"
	@echo "  make clean          - Remove all resources"
	@echo "  make status         - Show cluster status"
	@echo ""
	@echo "Scenario shortcuts:"
	@echo "  make s01            - Deploy scenario 01"
	@echo "  make s02            - Deploy scenario 02"
	@echo "  ... (s01-s10)"
	@echo ""

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
	@echo "Building and deploying self-healing demo apps..."
	@$(MAKE) -C scenarios/06-self-healing/demos docker-build
	@$(MAKE) -C scenarios/06-self-healing/demos kind-load
	@$(MAKE) -C scenarios/06-self-healing/demos deploy
	@echo ""
	@echo "Demo apps deployed!"
	@echo "View pods: kubectl get pods -l demo -w"

# Scenario shortcuts
s01:
	@echo "Deploying Scenario 01..."
	@kubectl apply -f scenarios/01-k8s-basics/exercises/
	@echo "Scenario 01 deployed!"

s02:
	@echo "Deploying Scenario 02..."
	@kubectl apply -f scenarios/02-config-secrets/exercises/
	@echo "Scenario 02 deployed!"

s03:
	@echo "Deploying Scenario 03..."
	@kubectl apply -f scenarios/03-networking/exercises/
	@echo "Scenario 03 deployed!"

s04:
	@echo "Deploying Scenario 04..."
	@kubectl apply -f scenarios/04-storage/exercises/
	@echo "Scenario 04 deployed!"

s05:
	@echo "Deploying Scenario 05..."
	@helm install myapp scenarios/05-helm-charts --values scenarios/05-helm-charts/values-dev.yaml
	@echo "Scenario 05 deployed!"

s06:
	@echo "Deploying Scenario 06 (self-healing demos)..."
	@$(MAKE) -C scenarios/06-self-healing/demos deploy
	@echo "Scenario 06 deployed!"

s07:
	@echo "Scenario 07 requires Prometheus - run make install-prometheus first"
	@kubectl apply -f scenarios/07-monitoring-basics/exercises/

s08:
	@echo "Scenario 08 requires Grafana - run make install-prometheus first"
	@echo "Access dashboards at: http://localhost:3000"

s09:
	@echo "Deploying Scenario 09 (OpenTelemetry)..."
	@kubectl apply -f scenarios/09-opentelemetry/exercises/

s10:
	@echo "Scenario 10 requires monitoring stack - run make install-prometheus first"
	@kubectl apply -f scenarios/10-production-ready/exercises/

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
