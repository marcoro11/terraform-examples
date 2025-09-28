# Scalable EKS Kubernetes Cluster with Automated CI/CD Pipeline

This project deploys a production-ready Kubernetes cluster on AWS EKS with automated CI/CD using ArgoCD and GitHub Actions. It includes comprehensive monitoring with Prometheus, Grafana, and Alertmanager, along with robust security best practices.

## Architecture

The project utilizes the following components:

*   **EKS Cluster:** A managed Kubernetes control plane with auto-scaling worker nodes.
*   **Networking:** VPC CNI provides pod networking, secured with RBAC and network policies.
*   **CI/CD Pipeline:** GitHub Actions triggers ArgoCD to deploy applications based on Git commits.
*   **Monitoring Stack:** Prometheus collects metrics, Grafana provides dashboards, and Alertmanager handles alerts.

```
┌─────────────────────────────────────────────────────────────┐
│                      EKS Cluster                            │
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │  Control Plane  │              │   Worker Nodes  │       │
│  │   (Managed)     │              │  (Auto Scaling) │       │
│  └─────────────────┘              └─────────────────┘       │
│           │                                │                │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │   Networking    │              │   Add-ons       │       │
│  │  VPC, Subnets   │              │ ALB, EBS, EFS   │       │
│  └─────────────────┘              └─────────────────┘       │
└─────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline                           │
│                                                             │
│  ┌─────────────┐    ┌──────────────-┐    ┌─────────────┐    │
│  │   GitHub    │───▶│ GitHub Actions│───▶│   ArgoCD    │    │
│  │   (Source)  │    │   (Build)     │    │  (Deploy)   │    │
│  └─────────────┘    └──────────────-┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                         │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │ Prometheus  │───▶│   Grafana    │───▶│  AlertMgr   │     │
│  │ (Metrics)   │    │ (Dashboard)  │    │ (Alerts)    │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```


## Features

*   **Managed EKS Cluster:** Simplified cluster management with auto-scaling.
*   **Automated CI/CD:** GitOps workflow using ArgoCD and GitHub Actions.
*   **Comprehensive Monitoring:** Real-time visibility into cluster health with Prometheus, Grafana, and Alertmanager.
*   **Robust Security:** RBAC, network policies, and Pod Security Standards enforce security best practices.

## Quick Start

1.  **Prerequisites:**
    *   An AWS account with appropriate permissions (IAM).
    *   `aws cli` installed and configured.
    *   `kubectl` installed and configured.

2.  **Deploy the Cluster:**
    ```bash
    terraform init       # Initialize the Terraform working directory

    terraform plan -var-file="terraform.tfvars"  # Review the changes
    terraform apply -var-file="terraform.tfvars" # Apply the configuration
    ```

3.  **Configure `kubectl`:**
    ```bash
    aws eks update-kubeconfig --region <your_region> --name <your_cluster_name>
    kubectl get nodes  # Verify cluster connectivity
    ```

## Project Structure

```
04-eks-cicd/
├── main.tf                            # Main Terraform configuration
├── variables.tf                       # Input variables
├── outputs.tf                         # Output values
├── terraform.tfvars                   # Example variables
└── modules/
    ├── eks-cluster/                   # EKS cluster with add-ons
    ├── vpc/                           # VPC for EKS
    ├── monitoring/                    # Prometheus/Grafana stack
    ├── argocd/                        # ArgoCD for GitOps
    ├── sample-app/                    # Sample application
    ├── aws-load-balancer-controller/  # ALB controller
    └── cluster-autoscaler/            # Cluster autoscaler
```

## ⚙️ Configuration

### Configuration Variables

| Variable          | Description                                  | Default Value | Required |
|-------------------|----------------------------------------------|---------------|----------|
| `cluster_name`    | Name of your EKS cluster                     | N/A           | Yes      |
| `cluster_version` | Kubernetes version (e.g., "1.28")            | N/A           | Yes      |
| `region`          | AWS region                                   | N/A           | Yes      |

### Optional Variables
- `node_groups`: Configuration for worker node groups
- `enable_monitoring`: Enable Prometheus/Grafana stack
- `enable_argocd`: Enable ArgoCD for GitOps
- `enable_cluster_autoscaler`: Enable cluster autoscaling

### Monitoring Stack
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and management
- **Node Exporter**: Node metrics

### CI/CD
- **ArgoCD**: GitOps continuous deployment
- **GitHub Actions**: CI pipeline integration
- **Helm**: Package management
