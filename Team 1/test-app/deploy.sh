#!/bin/bash

# Build and Deploy PostgreSQL Test App to GKE using Helm

set -e

APP_NAME="postgres-test-app"
IMAGE="asia-southeast1-docker.pkg.dev/new-devopts-k2-advance/app-repo/postgres-test-app:latest"
CHART_DIR="../helms/test-app"
VALUES_FILE="values-dev.yaml"
CLUSTER="app-cluster"
ZONE="asia-southeast1-a"
PROJECT="new-devopts-k2-advance"

echo "Getting GKE cluster credentials..."
gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT

echo "Building Docker image..."
docker build -t $IMAGE .

echo "Config docker credentials for Artifact Registry..."
gcloud auth configure-docker asia-southeast1-docker.pkg.dev

echo "Pushing image to Artifact Registry..."
docker push $IMAGE

echo "Deploying using Helm..."
cd $CHART_DIR

# Install or upgrade automatically depending on whether the release exists
if helm status $APP_NAME >/dev/null 2>&1; then
    echo "Release exists -> running helm upgrade..."
    helm upgrade $APP_NAME ./ -f $VALUES_FILE
else
    echo "Release does not exist -> running helm install..."
    helm install $APP_NAME ./ -f $VALUES_FILE
fi

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME

echo "Getting service external IP..."
kubectl get service ${APP_NAME}-service

echo "Deployment complete!"
echo "Test the application:"
echo "- Health check: curl http://[EXTERNAL-IP]/health"
echo "- Test query: curl http://[EXTERNAL-IP]/test-query"
