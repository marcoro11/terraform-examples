# Static Website Hosting on AWS with Terraform

This project automates the deployment of a static website to Amazon Web Services (AWS) using S3 for storage, CloudFront as a Content Delivery Network (CDN), ACM for SSL/TLS certificates, and Route 53 for DNS management.  It's designed to be a simple, cost-effective solution for hosting personal portfolios, documentation sites, or other static content.

## Architecture

The project utilizes the following AWS services:

*   **S3:** Stores the static website files.
*   **CloudFront:**  Distributes content globally via a CDN, improving performance and reducing latency.
*   **ACM:**  Provides an SSL/TLS certificate to enable HTTPS connections, securing your website.
*   **Route 53:**  Manages DNS records to point your domain name to the CloudFront distribution.

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Route53   │───▶│  CloudFront  │───▶│   S3 Web    │
│   (DNS)     │    │   (CDN/SSL)  │    │   Bucket    │
└─────────────┘    └──────────────┘    └─────────────┘
      │                  │
      │        ACM       │
      │     (SSL/TLS)    │
```


## Features

*   **Automated Deployment:**  Uses Terraform to provision and configure all necessary AWS resources.
*   **Secure HTTPS:** Automatically requests and validates an SSL/TLS certificate using ACM.
*   **Global Content Delivery:** Leverages CloudFront's CDN to accelerate content delivery worldwide.
*   **DNS Management:** Configures Route 53 records for seamless domain integration.

## Quick Start

1.  **Prerequisites:**
    *   An AWS account with appropriate permissions (IAM).
    *   Terraform installed and configured.
    *   A registered domain name.

2.  **Configuration:**
    Edit the `terraform.tfvars` file to provide your specific details:
    *   `domain_name`: Your registered domain name (e.g., `example.com`).
    *   `aws_region`: The AWS region you want to deploy to (e.g., `us-east-1`).

3.  **Deployment:**
    ```bash
    terraform init       # Initialize the Terraform working directory
    terraform plan        # Review the changes that will be applied
    terraform apply       # Apply the configuration and deploy the resources
    ```

## Project Structure

The project is organized as follows:

*   `main.tf`:  The main Terraform configuration file that orchestrates the deployment.
*   `variables.tf`: Defines the input variables used throughout the project (e.g., domain name, AWS region).
*   `outputs.tf`:  Defines the output values that provide information about the deployed resources (e.g., CloudFront domain name).
*   `terraform.tfvars`:  (Example file) Contains the variable definitions for your specific environment. **Do not commit sensitive information to this file.**
*   `modules/`: Contains reusable Terraform modules for each AWS service.
    *   `s3-website/`:  Module responsible for creating and configuring the S3 bucket.
    *   `cloudfront/`: Module responsible for creating and configuring the CloudFront distribution.
    *   `route53/`: Module responsible for creating and configuring the Route 53 records.
    *   `acm/`: Module responsible for requesting and validating the SSL certificate.