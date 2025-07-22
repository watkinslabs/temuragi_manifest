NAMESPACE = temuragi
KUBECTL = kubectl
K8S_DIR = resources

.PHONY: deploy delete deploy-infra deploy-app wait-for-postgres wait-for-job

# Deploy everything
deploy: deploy-infra wait-for-postgres deploy-app

# Deploy infrastructure (namespace, secrets, configmaps, postgres)
deploy-infra:
	$(KUBECTL) apply -f $(K8S_DIR)/0-namespace.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/1-pg-secrets.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/2-configmap.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/3-postgres-deployment.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/3-postgres-service.yaml

# Wait for postgres to be ready
wait-for-postgres:
	@echo "Waiting for postgres to be ready..."
	$(KUBECTL) wait --for=condition=ready pod -l app=postgres -n $(NAMESPACE) --timeout=300s


init:
	$(KUBECTL) apply -f $(K8S_DIR)/4-db-init.yaml
	@echo "Waiting for db init job to complete..."
	$(KUBECTL) wait --for=condition=complete job/temuragi-db-init -n $(NAMESPACE) --timeout=300s


# Deploy application after postgres is ready
deploy-app: init
	$(KUBECTL) apply -f $(K8S_DIR)/5-static-deployment.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/5-static-service.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/6-backend-deployment.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/6-backend-service.yaml
	$(KUBECTL) apply -f $(K8S_DIR)/7-ingress.yaml

# Delete everything
delete:
	$(KUBECTL) delete -f $(K8S_DIR)/7-ingress.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/6-backend-service.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/6-backend-deployment.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/5-static-service.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/5-static-deployment.yaml --ignore-not-found=true
	$(KUBECTL) delete job temuragi-db-init -n $(NAMESPACE) --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/3-postgres-service.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/3-postgres-deployment.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/2-configmap.yaml --ignore-not-found=true
	$(KUBECTL) delete -f $(K8S_DIR)/1-pg-secrets.yaml --ignore-not-found=true
	$(KUBECTL) delete namespace $(NAMESPACE) --ignore-not-found=true

# Quick status check
status:
	$(KUBECTL) get all -n $(NAMESPACE)