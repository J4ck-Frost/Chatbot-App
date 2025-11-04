# DevOps K2 Advanced - Team 1 Ray Infrastructure

This repository contains a complete Ray-powered distributed computing infrastructure on Google Kubernetes Engine.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐
│   Test App      │    │  Ray AI Model    │    │  Ray GPU Cluster   │
│  (PostgreSQL)   │    │   (FastAPI)      │    │  (Tesla P4 GPU)    │
│                 │    │                  │    │                    │
│ Todo + Chat +   │────│ Distributed AI   │────│ Ray Head + Workers │
│ File Upload     │    │ Inference        │    │ GPU Computing      │
└─────────────────┘    └──────────────────┘    └────────────────────┘
```

## Key Services

### 1. Ray GPU Cluster
- **Purpose**: Distributed computing with GPU acceleration
- **Hardware**: nvidia-tesla-p4 GPU on n1-standard-4
- **Access**: http://35.240.176.181 (Ray AI Model API)
- **Features**: Parallel processing, GPU training, distributed actors

### 2. Test Application  
- **Purpose**: Full-stack web application with database
- **Access**: http://136.110.11.5
- **Features**: Todo management, mock file upload, mock chat API
- **Database**: PostgreSQL with persistent storage

### 3. Ray-Powered AI Model
- **Purpose**: AI inference with Ray distributed computing
- **Access**: http://35.240.176.181
- **Features**: Single prediction, batch processing, cluster monitoring
- **Integration**: Connected to Ray GPU cluster for distributed inference

## Quick Start

### Deploy Ray Infrastructure
```bash
# Deploy Ray cluster with GPU
kubectl apply -f ray-deployment/security/ray-rbac.yaml
kubectl apply -f ray-deployment/cluster/ray-gpu-cluster.yaml

# Deploy Ray-powered AI model
kubectl create configmap ray-ai-model-code --from-file=ai-model/ray_model_server.py
kubectl apply -f ai-model/ray-ai-model-deployment.yaml
```

### Deploy Test Application
```bash
kubectl apply -f test-app/k8s-deployment.yaml
```

### Run Ray Demo
```bash
cd ray-deployment/demos/
kubectl create configmap ray-demo-script --from-file=ray-demo.py
kubectl apply -f ray-demo.yaml
kubectl logs -l app=ray-demo -f
```

## Directory Structure

```
Team 1/
├── ai-model/                    # Ray-powered AI service
│   ├── ray_model_server.py      # FastAPI + Ray integration
│   ├── ray-ai-model-deployment.yaml
│   └── Dockerfile.ray
├── ray-deployment/              # Ray cluster configuration
│   ├── cluster/                 # Core cluster setup
│   ├── demos/                   # Ray demo applications
│   ├── security/                # RBAC and authentication
│   └── README.md
├── test-app/                    # Web application
│   ├── app.js                   # Node.js + PostgreSQL
│   ├── k8s-deployment.yaml
│   └── public/                  # Frontend assets
├── environments/                # Terraform environments
└── modules/                     # Terraform modules
```

## API Endpoints

### Ray AI Model Service (http://35.240.176.181)
- `GET /` - Service info with Ray cluster status
- `GET /health` - Health check + Ray connection
- `GET /cluster-info` - Ray cluster resources
- `POST /predict` - Single prediction using Ray
- `POST /batch-predict` - Parallel batch processing

### Test App (http://136.110.11.5)
- `GET /` - Web interface
- `GET /api/todos` - Todo management
- `POST /api/upload` - Mock file upload
- `POST /api/chat` - Mock chat API

## Monitoring

```bash
# Check Ray cluster status
kubectl get pods -l app=ray-gpu-cluster-head

# Monitor Ray AI model
kubectl logs -l app=ray-ai-model -f

# Check all services
kubectl get svc
```

## Key Features

- **GPU Acceleration**: Tesla P4 GPU for ML workloads
- **Distributed Computing**: Ray cluster for parallel processing  
- **Scalable AI**: FastAPI with Ray integration
- **Full-Stack App**: Node.js + PostgreSQL + Frontend
- **Container Orchestration**: Kubernetes on GKE
- **Infrastructure as Code**: Terraform for reproducible deployments

## Cleanup

```bash
# Remove Ray resources
kubectl delete -f ai-model/ray-ai-model-deployment.yaml
kubectl delete -f ray-deployment/cluster/ray-gpu-cluster.yaml
kubectl delete -f ray-deployment/security/ray-rbac.yaml

# Remove test app
kubectl delete -f test-app/k8s-deployment.yaml
```