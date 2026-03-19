AWS_REGION=eu-central-1
ACCOUNT_ID=735339530721

REPOSITORY_NAME=word-cloud-generator
CLUSTER_NAME=word-cloud-cluster
SERVICE_NAME=word-cloud-service

IMAGE_TAG=latest
IMAGE_URI=$(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(REPOSITORY_NAME):$(IMAGE_TAG)

deploy:
	@echo "Login to ECR"
	aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

	@echo "Build Docker image"
	docker build -t $(REPOSITORY_NAME):$(IMAGE_TAG) .

	@echo "Tag image"
	docker tag $(REPOSITORY_NAME):$(IMAGE_TAG) $(IMAGE_URI)

	@echo "Push to ECR"
	docker push $(IMAGE_URI)

	@echo "Force new deployment on ECS"
	aws ecs update-service \
		--cluster $(CLUSTER_NAME) \
		--service $(SERVICE_NAME) \
		--force-new-deployment \
		--region $(AWS_REGION)