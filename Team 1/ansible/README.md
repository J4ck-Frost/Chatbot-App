# Ray AI Model Deployment with Ansible

This Ansible automation deploys a complete Ray AI infrastructure including Ray cluster, Phi3 AI model services, and test application.

## Quick Start

### Prerequisites
- Docker running locally
- kubectl configured with access to your Kubernetes cluster
- Ansible installed (`pip install ansible`)

### 1. Install Required Collections
```bash
cd "Team 1/ansible"
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Variables
Edit `group_vars/all.yml` to match your environment:
```yaml
gcp_project_id: "your-actual-project-id"
gcp_region: "your-region" 
gcp_artifact_registry: "your-registry-url"
# ... other settings
```

### 3. Deploy Everything
```bash
# Option A: Use the deployment script (recommended)
chmod +x deploy.sh
./deploy.sh

# Option B: Run Ansible directly
ansible-playbook -i inventory site.yml
```

## What Gets Deployed

1. **Docker Images**
   - Ray Serve (AI model server)
   - Ray Worker (AI model worker) 
   - Test App (Node.js frontend)

2. **Ray Cluster**
   - Head node with dashboard
   - GPU worker nodes
   - Client access endpoints

3. **AI Model Services**
   - Phi3 Ray Serve deployment
   - Phi3 Worker deployment
   - Health checks and monitoring

4. **Test Application**
   - Node.js chat interface
   - API endpoints for testing AI models

## Deployment Options

### Skip Terraform (Default)
```bash
ansible-playbook -i inventory site.yml --tags docker,kubernetes
```

### Include Terraform Infrastructure  
```bash
ansible-playbook -i inventory site.yml -e deploy_terraform=true
```

### Build Only Docker Images
```bash
ansible-playbook -i inventory site.yml --tags docker
```

### Deploy Only to Kubernetes
```bash
ansible-playbook -i inventory site.yml --tags kubernetes
```

## Post-Deployment

### Access Ray Dashboard
```bash
kubectl port-forward svc/ray-cluster-head-svc 8265:8265
# Open: http://localhost:8265
```

### Check Deployment Status
```bash
kubectl get pods
kubectl get svc
kubectl logs -l app=phi3-ray-serve
```

### Test AI Model
```bash
kubectl port-forward svc/phi3-worker-service 8000:8000
curl -X POST http://localhost:8000/chat -H "Content-Type: application/json" -d '{"message": "Hello AI!"}'
```

## Troubleshooting

### Common Issues

1. **Docker build fails**
   - Ensure Docker has enough memory allocated
   - Check internet connectivity for package downloads

2. **Ray cluster not ready**
   - Check node selectors match your cluster nodes
   - Verify GPU nodes are available (for GPU workers)

3. **AI models not starting**
   - Check logs: `kubectl logs -l app=phi3-ray-serve`
   - Verify Ray head service is accessible
   - Check resource limits vs available cluster resources

### Debug Commands
```bash
# Check all resources
kubectl get all

# View detailed pod status
kubectl describe pods

# Check events
kubectl get events --sort-by='.lastTimestamp'

# View logs for specific component
kubectl logs deployment/phi3-ray-serve
kubectl logs deployment/phi3-worker-model
```

## Configuration Reference

### Variables in `group_vars/all.yml`
- `gcp_project_id`: Your GCP project ID
- `gcp_region`: GCP region for resources
- `gcp_artifact_registry`: Docker registry URL
- `namespace`: Kubernetes namespace (default: default)
- `wait_timeout`: Max wait time for deployments (default: 300s)
- `health_check_retries`: Health check retry count (default: 10)

### Directory Structure
```
Team 1/ansible/
├── ansible.cfg              # Ansible configuration
├── deploy.sh                # Deployment script
├── inventory                # Host inventory
├── requirements.yml         # Ansible collections
├── site.yml                 # Main playbook
├── group_vars/
│   └── all.yml              # Variables
└── roles/
    ├── docker/              # Docker build/push
    ├── k8s/                 # Kubernetes deployment
    └── terraform/           # Infrastructure (optional)
```