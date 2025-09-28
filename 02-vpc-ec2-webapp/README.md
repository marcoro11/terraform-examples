# Scalable Web Application Stack on AWS with Terraform

This project deploys a highly available and scalable web application stack to Amazon Web Services (AWS) using Terraform. It includes an Application Load Balancer, auto-scaling EC2 instances, a managed RDS MySQL database with read replicas, and comprehensive monitoring.  It's designed for production environments requiring reliability, scalability, and security.

## Architecture

The project utilizes the following AWS services:

*   **VPC:** A Virtual Private Cloud provides a logically isolated network for the application.
*   **Application Load Balancer (ALB):** Distributes incoming traffic across multiple EC2 instances, improving availability and scalability.
*   **EC2 Instances (Auto Scaling Group):**  Dynamically scales the number of web servers based on CPU utilization, ensuring optimal performance.
*   **RDS MySQL (Primary & Read Replicas):** A managed relational database service with automated backups and read replicas for improved performance.
*   **Security Groups:** Control network traffic to and from the application components, enhancing security.

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│                                                            │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   Public AZ-A   │              │   Public AZ-B   │      │
│  │  (10.0.1.0/24)  │              │  (10.0.2.0/24)  │      │
│  │                 │              │                 │      │
│  │  ┌─────────────┐│              │┌─────────────┐  │      │
│  │  │     ALB     ││              ││   Bastion   │  │      │
│  │  └─────────────┘│              │└─────────────┘  │      │
│  └─────────────────┘              └─────────────────┘      │
│           │                                │               │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  Private AZ-A   │              │  Private AZ-B   │      │
│  │  (10.0.3.0/24)  │              │  (10.0.4.0/24)  │      │
│  │                 │              │                 │      │
│  │  ┌─────────────┐│              │┌─────────────┐  │      │
│  │  │ Web Servers ││              ││ Web Servers │  │      │
│  │  │    (ASG)    ││              ││    (ASG)    │  │      │
│  │  └─────────────┘│              │└─────────────┘  │      │
│  └─────────────────┘              └─────────────────┘      │
│           │                                │               │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │    DB AZ-A      │              │    DB AZ-B      │      │
│  │  (10.0.5.0/24)  │              │  (10.0.6.0/24)  │      │
│  │                 │              │                 │      │
│  │  ┌─────────────┐│              │┌─────────────┐  │      │
│  │  │     RDS     ││──────────────││  RDS Read   │  │      │
│  │  │  (Primary)  ││              ││  Replica    │  │      │
│  │  └─────────────┘│              │└─────────────┘  │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Features

*   **High Availability:** Multi-AZ deployment with automatic failover.
*   **Scalability:** Auto Scaling Group dynamically adjusts the number of web servers based on demand.
*   **Database Performance:** Read replicas improve read performance and reduce load on the primary database.
*   **Security:** Private subnets, security groups with least privilege access, and regular backups.
*   **Monitoring:** CloudWatch dashboards provide real-time visibility into application health and performance.

## Quick Start

1.  **Prerequisites:**
    *   An AWS account with appropriate permissions (IAM).
    *   Terraform installed and configured.
    *   An SSH key pair for accessing the EC2 instances.

2.  **Configuration:**
    Edit the `terraform.tfvars` file to provide your specific details:
    *   `project_name`: A unique name for your project.
    *   `environment`: The environment (e.g., `dev`, `staging`, `prod`).
    *   `key_pair_name`: The name of your SSH key pair.

3.  **Deployment:**
    ```bash
    terraform init       # Initialize the Terraform working directory
    terraform plan        # Review the changes that will be applied
    terraform apply       # Apply the configuration and deploy the resources
    ```

## Project Structure

```
02-vpc-ec2-webapp/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── terraform.tfvars       # Variable values
└── modules/
    ├── vpc/               # VPC and networking module
    ├── security/          # Security groups module
    ├── compute/           # EC2 and Auto Scaling module
    ├── database/          # RDS and ElastiCache module
    └── monitoring/        # CloudWatch monitoring module
```

## Configuration Variables

| Variable        | Description                                  | Default Value | Required |
|-----------------|----------------------------------------------|---------------|----------|
| `project_name`  | A unique name for your project               | N/A           | Yes      |
| `environment`   | The environment (e.g., dev, staging, prod)   | N/A           | Yes      |
| `key_pair_name` | The name of your SSH key pair                | N/A           | Yes      |
| `vpc_cidr`      | The VPC CIDR block                           | "10.0.0.0/16" | No       |
| `instance_type` | The EC2 instance type                        | "t3.medium"   | No       |