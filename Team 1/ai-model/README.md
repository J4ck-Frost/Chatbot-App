# Phi3-Mini on Ray Worker

This directory contains the configuration for hosting Phi3-mini model directly on Ray worker.

## Files:
- `phi3_worker_host.py` - Python script that hosts Phi3-mini model on Ray worker
- `phi3-worker-deployment.yaml` - Kubernetes job deployment

## Deployment Steps:

### 1. Create ConfigMap from Python file:
```bash
kubectl create configmap phi3-worker-script --from-file=ai-model/phi3_worker_host.py --dry-run=client -o yaml | kubectl apply -f -
```

### 2. Deploy the worker:
```bash
kubectl apply -f ai-model/phi3-worker-deployment.yaml
```

### 3. Check deployment:
```bash
kubectl get pods | grep phi3
kubectl logs <pod-name> -f
```

## Architecture:
- **Ray Head**: Coordinator on CPU node
- **Ray Worker**: Hosts Phi3-mini model directly with GPU access (0.7 GPU, 1.5 CPU)
- **ConfigMap**: Contains the Python script for model hosting

## Benefits:
- ✅ Direct GPU access without networking overhead
- ✅ No separate AI service pods needed
- ✅ Efficient resource utilization
- ✅ Clean separation of code and configuration