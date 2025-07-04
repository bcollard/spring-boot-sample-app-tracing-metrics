.ONESHELL:
.DEFAULT_GOAL := help
.PHONY: help build push convert tag deploy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# =====================================================

DOCKER_TAG = 0.0.1-SNAPSHOT
DOCKER_REGISTRY = pileenretard

convert: ## convert the original docker compose to k8s
	@echo "Converting Docker Compose to Kubernetes"
	@kompose convert

build: ## build the docker images
	@echo "Building Docker Images"
	@mvn spring-boot:build-image

tag: build ## tag the docker images
	@echo "Tagging Docker Images"
	@docker tag httpservice1-micrometer:$(DOCKER_TAG) $(DOCKER_REGISTRY)/httpservice1-micrometer:$(DOCKER_TAG)
	@docker tag httpservice2-micrometer:$(DOCKER_TAG) $(DOCKER_REGISTRY)/httpservice2-micrometer:$(DOCKER_TAG)

push: tag ## push the docker images to the registry
	@echo "Pushing Docker Images"
	@docker push $(DOCKER_REGISTRY)/httpservice1-micrometer:$(DOCKER_TAG)
	@docker push $(DOCKER_REGISTRY)/httpservice2-micrometer:$(DOCKER_TAG)

deploy: ## install on the current k8s cluster
	@echo "Deploying to Kubernetes"
	@kubectl apply -f deploy/k8s/mesh/httpservice1-deployment.yaml
	@kubectl apply -f deploy/k8s/mesh/httpservice2-deployment.yaml
	@kubectl apply -f deploy/k8s/mesh/httpservice1-service.yaml
	@kubectl apply -f deploy/k8s/mesh/httpservice2-service.yaml

deploy-no-mesh: ## install on the current k8s cluster without the service mesh
	@echo "Deploying to Kubernetes without the service mesh"
	@kubectl apply -f deploy/k8s/no-mesh/httpservice1-deployment.yaml
	@kubectl apply -f deploy/k8s/no-mesh/httpservice2-deployment.yaml
	@kubectl apply -f deploy/k8s/no-mesh/httpservice1-service.yaml
	@kubectl apply -f deploy/k8s/no-mesh/httpservice2-service.yaml

