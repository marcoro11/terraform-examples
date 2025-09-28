# Terraform Infrastructure Examples

This repository provides a collection of practical Terraform configurations demonstrating modern cloud infrastructure patterns, security best practices, and DevOps automation.  Each project is designed to be deployed as-is or adapted for your specific needs.

## Projects Overview

### 1. [Static Portfolio on S3](./01-s3-static-portfolio/)
- **Description**:  Deploys a static website hosted on S3, fronted by CloudFront for fast content delivery and secured with HTTPS.  This project is ideal for simple websites, documentation sites, or landing pages.
- **Key Components**: S3 bucket, CloudFront distribution with custom domain and SSL certificate (ACM), Route53 DNS records.
- **Use Cases**: Personal portfolio, documentation site, landing page.

### 2. [VPC + EC2 Web Application Stack](./02-vpc-ec2-webapp/)
- **Description**:  A complete web application infrastructure built on a VPC with EC2 instances, load balancing, and auto-scaling. This project demonstrates how to build a highly available and scalable web application on AWS.
- **Key Components**: VPC with public/private subnets, EC2 instances in an Auto Scaling Group (ASG), Application Load Balancer (ALB), RDS MySQL database, ElastiCache Redis for caching.
- **Use Cases**: Web application with moderate traffic and scalability requirements.

### 3. [Multi-Environment DNS Management](./03-multi-env-dns/)
- **Description**:  Manages infrastructure across multiple environments (dev, staging, prod) with automated DNS and TLS certificate management. This project demonstrates how to use Terraform workspaces to isolate environments and streamline deployments.
- **Key Components**: Route53 DNS records for each environment, ACM certificates managed automatically, CloudFront CDN distribution.
- **Use Cases**:  Development, staging, and production environments for a web application.

### 4. [EKS Kubernetes Cluster + CI/CD](./04-eks-cicd/)
- **Description**:  Deploys a production-grade Kubernetes cluster on EKS with a complete CI/CD pipeline using ArgoCD and monitoring with Prometheus and Grafana. This project demonstrates how to automate deployments and monitor your Kubernetes cluster.
- **Key Components**: EKS cluster, Helm package manager, ArgoCD for GitOps deployments, Prometheus and Grafana monitoring stack.
- **Use Cases**:  Microservices application deployed on Kubernetes.

### 5. [Serverless Application Stack](./05-serverless-app/)
- **Description**:  Deploys a complete serverless architecture with REST API, authentication, and database. This project demonstrates how to build scalable and cost-effective serverless applications on AWS.
- **Key Components**: Lambda functions, API Gateway REST API, DynamoDB database, Cognito authentication service.
- **Use Cases**:  API backend for a web or mobile application.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/marcoro11/terraform-examples.git
cd terraform-examples

# Choose a project
cd 01-s3-static-portfolio

# Initialize and plan
terraform init
terraform plan

# Apply infrastructure
terraform apply
```

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Git for version control

## Key Considerations
- Security: Each project incorporates security best practices, including encryption, IAM roles with least privilege access.
- Scalability: Projects are designed to scale based on traffic and demand.
- Cost Optimization: Resource sizing is optimized for cost-effectiveness.
