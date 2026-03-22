# ==========================
# Variables
# ==========================
REGISTRY ?= myregistry.azurecr.io
IMAGE_NAME ?= word-cloud-generator
TAG ?= latest
IMAGE_URI=$(REGISTRY)/$(IMAGE_NAME):$(TAG)

# ==========================
# Test
# ==========================
test:
	@echo "Running Go tests..."
	go test $(shell go list ./... | grep -v vendor) -v

# ==========================
# Build
# ==========================
build:
	@echo "Building Go binary..."
	GOOS=linux GOARCH=amd64 go build -o ./bin/word-cloud-generator main.go

# ==========================
# Deploy to Azure Container Apps
# ==========================
deploy: build
	@echo "Login to ACR"
	docker login $(REGISTRY) -u $(ACR_USERNAME) -p $(ACR_PASSWORD)

	@echo "Build Docker image"
	docker build -t $(IMAGE_URI) .

	@echo "Push image to ACR"
	docker push $(IMAGE_URI)

	@echo "Deploy to Azure Container Apps"
	az containerapp update \
		--name $(CONTAINER_APP_NAME) \
		--resource-group $(RESOURCE_GROUP) \
		--image $(IMAGE_URI)