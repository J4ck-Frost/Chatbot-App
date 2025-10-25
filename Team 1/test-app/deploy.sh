#!/bin/bash

# Build and Deploy PostgreSQL Test App to GKE

echo "Getting GKE cluster credentials..."
gcloud container clusters get-credentials gke-cluster-dev --zone=asia-southeast1-a --project=devopts-k2-advance

echo "Building Docker image..."
docker build -t asia-southeast1-docker.pkg.dev/devopts-k2-advance/team1-ai-repo/postgres-test-app:latest .

echo "Pushing image to Artifact Registry..."
docker push asia-southeast1-docker.pkg.dev/devopts-k2-advance/team1-ai-repo/postgres-test-app:latest

echo "Updating Kubernetes deployment with correct image..."
sed -i 's|image: postgres-test-app:latest|image: asia-southeast1-docker.pkg.dev/devopts-k2-advance/team1-ai-repo/postgres-test-app:latest|g' k8s-deployment.yaml

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