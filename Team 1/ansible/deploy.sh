#!/bin/bash

echo "🚀 Ray AI Model Deployment Script"
echo "================================="

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi
echo "✅ Docker is running"

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    echo "❌ kubectl not found. Please install kubectl and try again."
    exit 1
fi
echo "✅ kubectl is available"

# Check if Ansible is available
if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "❌ ansible-playbook not found. Please install Ansible and try again."
    exit 1
fi
echo "✅ Ansible is available"

# Install required Ansible collections
echo "📦 Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml --force

# Run the deployment
echo "🚀 Starting Ray AI deployment..."
echo "This will deploy:"
echo "  - Docker images for AI models"
echo "  - Ray cluster with head and workers"  
echo "  - Phi3 AI model services"
echo "  - Test application"

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ansible-playbook -i inventory site.yml --tags docker,kubernetes
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Deployment completed successfully!"
        echo ""
        echo "Quick commands to get started:"
        echo "# View all pods:"
        echo "kubectl get pods"
        echo ""
        echo "# Access Ray dashboard:"
        echo "kubectl port-forward svc/ray-cluster-head-svc 8265:8265"
        echo "# Then open: http://localhost:8265"
        echo ""
        echo "# Check AI model logs:"
        echo "kubectl logs -l app=phi3-ray-serve"
        echo "kubectl logs -l app=phi3-worker-model"
    else
        echo "❌ Deployment failed. Check the logs above for details."
        exit 1
    fi
else
    echo "Deployment cancelled."
fi