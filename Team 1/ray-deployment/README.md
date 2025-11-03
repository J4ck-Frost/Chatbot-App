# Ray GPU Cluster Deployment

This directory contains all the configurations and demos for the Ray GPU cluster on Google Kubernetes Engine.

## Directory Structure

```
ray-deployment/
├── cluster/           # Core cluster configurations
│   ├── ray-gpu-cluster.yaml    # Main GPU cluster setup
│   └── ray-client-pod.yaml     # Client pod for cluster access
├── demos/             # Demo applications and examples
│   ├── ray-demo.py             # Python demo script
│   └── ray-demo.yaml           # Kubernetes job to run demo
├── security/          # Security and access configurations
│   ├── ray-rbac.yaml           # Role-based access control
│   └── PASSWORD-MANAGEMENT.md  # Security documentation
└── README.md          # This file
```

## Quick Start

### 1. Deploy the Ray GPU Cluster
```bash
kubectl apply -f security/ray-rbac.yaml
kubectl apply -f cluster/ray-gpu-cluster.yaml
```

### 2. Run a Demo
```bash
cd demos/
kubectl create configmap ray-demo-script --from-file=ray-demo.py
kubectl apply -f ray-demo.yaml
kubectl logs -l app=ray-demo -f
```

### 3. Access the Cluster
```bash
kubectl apply -f cluster/ray-client-pod.yaml
kubectl exec -it ray-client -- /bin/bash
```

## Cluster Details

- **GPU Node**: n1-standard-4 with nvidia-tesla-p4
- **Location**: asia-southeast1-b
- **Ray Version**: 2.8.0
- **Security**: ClusterIP with RBAC authentication

## Demo Features

The ray-demo.py includes:
- Parallel function execution
- GPU model training simulation
- Distributed actors (stateful objects)
- Data processing pipelines
- Cluster resource monitoring

## Cleanup

```bash
kubectl delete -f demos/ray-demo.yaml
kubectl delete -f cluster/ray-client-pod.yaml
kubectl delete -f cluster/ray-gpu-cluster.yaml
kubectl delete -f security/ray-rbac.yaml
```