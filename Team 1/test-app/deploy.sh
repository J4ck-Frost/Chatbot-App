#!/bin/bash

# Build and Deploy PostgreSQL Test App to GKE

echo "Getting GKE cluster credentials..."
gcloud container clusters get-credentials app-cluster --zone=asia-southeast1-a --project=new-devopts-k2-advance

echo "Building Docker image..."
docker build -t asia-southeast1-docker.pkg.dev/new-devopts-k2-advance/app-repo/postgres-test-app:latest .

echo "Config docker credentials for Artifact Registry..."
gcloud auth configure-docker asia-southeast1-docker.pkg.dev

echo "Pushing image to Artifact Registry..."
docker push asia-southeast1-docker.pkg.dev/new-devopts-k2-advance/app-repo/postgres-test-app:latest

echo "Deploying to GKE..."
kubectl apply -f k8s-deployment.yaml

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres-test-app

echo "Getting service external IP..."
kubectl get service postgres-test-app-service

echo "Deployment complete!"
echo "Test the application:"
echo "- Health check: curl http://[EXTERNAL-IP]/health"
echo "- Test query: curl http://[EXTERNAL-IP]/test-query"