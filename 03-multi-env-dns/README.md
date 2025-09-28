# Scalable Multi-Environment Infrastructure with Terraform Workspaces

This project deploys a scalable infrastructure across development, staging, and production environments using Terraform workspaces. It automates DNS configuration with Route 53 and manages SSL/TLS certificates for each environment, enabling independent deployments and testing.

## Architecture

The project utilizes Terraform workspaces to isolate each environment:

*   **Development:** A low-cost environment for experimentation and testing.
*   **Staging:** A production-like environment for pre-release validation.
*   **Production:** The live environment serving end-users.

Each environment includes:

*   **Route 53:**  Manages DNS records for the respective subdomain (e.g., dev.yourdomain.com).
*   **SSL/TLS Certificates:**  Automatic provisioning and renewal of certificates for secure HTTPS connections.
*   **Application Infrastructure:** (Not detailed here, but could include EC2 instances, Load Balancers, etc.)

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Environment                   │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │   Route53   │───▶│  CloudFront  │───▶│   S3/ALB    │     │
│  │prod.app.com │    │  (prod SSL)  │    │  (prod app) │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Staging Environment                      │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │   Route53   │───▶│  CloudFront  │───▶│   S3/ALB    │     │
│  │stage.app.com│    │ (stage SSL)  │    │ (stage app) │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  Development Environment                    │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │   Route53   │───▶│  CloudFront  │───▶│   S3/ALB    │     │
│  │ dev.app.com │    │  (dev SSL)   │    │  (dev app)  │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```


## Features

*   **Environment Isolation:** Terraform workspaces provide clean separation between environments.
*   **Automated DNS Management:** Route 53 configuration is automated for each environment.
*   **SSL/TLS Automation:** Certificates are automatically provisioned and renewed, ensuring secure connections.
*   **Scalability:**  Each environment can be scaled independently to meet its specific needs.

## Quick Start

1.  **Prerequisites:**
    *   An AWS account with appropriate permissions (IAM).
    *   Terraform installed and configured.
    *   A registered domain name.

2.  **Configure Root Domain:**
    Set the `TF_VAR_root_domain` environment variable to your registered domain name (e.g., `yourdomain.com`).

3.  **Create and Deploy Environments:**
    ```bash
    terraform init       # Initialize the Terraform working directory

    # Create and deploy the development environment
    terraform workspace new dev
    terraform plan -var-file="environments/dev.tfvars"
    terraform apply -var-file="environments/dev.tfvars"

    # Repeat for staging and production
    terraform workspace new staging
    terraform plan -var-file="environments/staging.tfvars"
    terraform apply -var-file="environments/staging.tfvars"

    terraform workspace new prod
    terraform plan -var-file="environments/prod.tfvars"
    terraform apply -var-file="environments/prod.tfvars"
    ```

4.  **Switch Between Environments:**
    ```bash
    terraform workspace list       # List available workspaces

    terraform workspace select <environment>  # Switch to the desired environment
    ```

## Project Structure

```
03-multi-env-dns/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                # Output values
├── environments/             # Environment-specific configurations
│   ├── dev.tfvars           # Development environment variables
│   ├── staging.tfvars       # Staging environment variables
│   └── prod.tfvars          # Production environment variables
├── modules/
│   ├── dns/                 # DNS and certificate management
│   ├── cdn/                 # CloudFront distribution
│   └── application/         # Application infrastructure
└── scripts/
    ├── deploy.sh           # Deployment automation script
    └── destroy.sh          # Environment cleanup script
```

## ⚙️ Environment Configuration

### Development (dev.tfvars)
- **Domain**: dev.yourdomain.com
- **Resources**: Minimal (t3.micro, single AZ)

### Staging (staging.tfvars)
- **Domain**: staging.yourdomain.com
- **Resources**: Production-like (t3.small, multi-AZ)

### Production (prod.tfvars)
- **Domain**: yourdomain.com (apex) + www.yourdomain.com
- **Resources**: High availability (t3.medium+, multi-AZ, auto-scaling)

## 🔧 Workspace Management

### Common Commands
```bash
# List all workspaces
terraform workspace list

# Create new workspace
terraform workspace new <environment>

# Switch workspace
terraform workspace select <environment>

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete <environment>
```

### Environment-Specific Operations
```bash
# Deploy to specific environment
./scripts/deploy.sh dev
./scripts/deploy.sh staging
./scripts/deploy.sh prod

# Check outputs for current environment
terraform output

# Plan changes for specific environment
terraform plan -var-file="environments/$(terraform workspace show).tfvars"
```
