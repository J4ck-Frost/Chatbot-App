# Team 1 – AI Infrastructure & Monitoring System

This project provides an automated Kubernetes-based infrastructure on **Google Kubernetes Engine (GKE)** for deploying **AI workloads (Ray Framework)** and a centralized **Monitoring & Logging stack (Prometheus, Grafana, Loki)**.

The system is fully provisioned and managed using **Terraform**, **Ansible**, and standard cloud-native tools.

---

## Technology Stack

- Cloud Provider: Google Cloud Platform (GCP)
- Infrastructure as Code: Terraform
- Container Orchestration: Kubernetes (GKE)
- Configuration Management: Ansible
- Monitoring & Logging: Prometheus, Grafana, Loki (PLG Stack)
- AI Model: Qwen2.5-7B
- AI Framework: Ray (Python)
- Package & CLI Tools: gcloud, kubectl, helm, Docker

---

## Project Structure

```text
Team 1/
├── ai-model/            # AI model training / inference source code
├── ansible/             # Ansible playbooks (monitoring, ray, chatbot)
├── chatbot-app/         # Web-based chatbot application (UI)
├── environments/        # Terraform environment configurations (dev, staging, ...)
├── helms/               # Custom Helm charts
├── modules/             # Reusable Terraform modules
└── ray-deployment/      # Kubernetes manifests for Ray cluster deployment
````

---

## How to Run the System (Single Command)

```bash
cd "../../ansible"
ansible-playbook -i inventory site.yml
```

The playbook deploys:

* Prometheus, Grafana, Loki
* Ray Cluster and Ray Dashboard
* Chatbot UI

---

## Accessing Service Endpoints

```bash
kubectl get svc -A
```

Grafana:

```bash
kubectl get svc -n monitoring
# Access: http://<GRAFANA_LOADBALANCER_IP>:80
# User: admin / Pass: admin
```

Ray Dashboard:

```bash
kubectl get svc -n ray
# Access: http://<RAY_HEAD_SERVICE_IP>:8265
```

Chatbot UI:

```bash
kubectl get svc -n chatbot
# Access: http://<CHATBOT_SERVICE_IP>
```

```

---
