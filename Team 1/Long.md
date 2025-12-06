gcloud builds submit --tag asia-southeast1-docker.pkg.dev/striking-figure-474817-a3/team1-ai-repo/qwen2-serve:v1 .
kuberay-operator
kubectl apply -f qwen-ray-serve-deployment.yaml
kubectl apply -f ray-client-pod.yaml
kubectl apply -f secret.yaml
kubectl apply -f ray-rbac.yaml
kubectl apply -f ray-cluster.yaml

terraform state rm module.artifact_registry.google_artifact_registry_repository_iam_member.gke_pull

gcloud container clusters get-credentials gke-cluster-dev --zone=asia-southeast1-a



