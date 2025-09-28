# Scalable Serverless Application Stack on AWS

This project deploys a fully serverless application stack on AWS using Lambda, API Gateway, DynamoDB, and Cognito. It includes automated CI/CD with GitHub Actions and robust security features to protect your application and data.

## Architecture

The project utilizes the following components:

*   **Frontend:** Static website hosted on S3 and served via CloudFront CDN.
*   **API Layer:** RESTful API built with API Gateway and Lambda functions.
*   **Data Layer:** DynamoDB provides a high-performance NoSQL database, and Cognito handles user authentication.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │   Route53   │───▶│  CloudFront  │───▶│   S3 Web    │     │
│  │    (DNS)    │    │    (CDN)     │    │  (Frontend) │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────────┐
│                     API Layer                               │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │     WAF     │───▶│ API Gateway  │───▶│   Lambda    │     │
│  │ (Security)  │    │   (REST)     │    │ Functions   │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐     │
│  │  DynamoDB   │    │   Cognito    │    │     S3      │     │
│  │ (Database)  │    │    (Auth)    │    │ (Storage)   │     │
│  └─────────────┘    └──────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Features

*   **Fully Serverless:** No server management, automatic scaling.
*   **RESTful API:** Built with API Gateway and Lambda functions for flexible backend logic.
*   **Secure Authentication:** Cognito User Pools provide secure user management and authentication.
*   **High-Performance Database:** DynamoDB offers a scalable NoSQL database for fast data access.

## Quick Start

1.  **Deploy Infrastructure:**
    ```bash
    terraform init       # Initialize the Terraform working directory

    terraform plan -var-file="terraform.tfvars"  # Review the changes
    terraform apply -var-file="terraform.tfvars" # Apply the configuration
    ```

2.  **Deploy Application Code:** (Requires configuring Lambda functions and frontend assets)
    ```bash
    # Package and deploy Lambda functions (configure scripts as needed)
    ./scripts/deploy-functions.sh

    # Deploy frontend to S3 (configure scripts as needed)
    ./scripts/deploy-frontend.sh
    ```

## Project Structure

```
05-serverless-app/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                # Output values
├── terraform.tfvars          # Example variables
└── modules/
    ├── api-gateway/          # API Gateway with REST endpoints
    ├── lambda/               # Lambda functions (14 total)
    ├── dynamodb/             # DynamoDB tables and configuration
    ├── cognito/              # Cognito User Pool for auth
    ├── s3/                   # S3 buckets for storage and hosting
    ├── monitoring/           # CloudWatch monitoring and alerts
    └── waf/                  # WAF for API protection
```

## 🔧 Configuration


## Configuration Variables

| Variable                | Description                                  | Default Value | Required |
|-------------------------|----------------------------------------------|---------------|----------|
| `STAGE`                 | Deployment stage (dev, staging, prod)        | N/A           | Yes      |
| `AWS_REGION`            | AWS region                                   | N/A           | Yes      |
| `COGNITO_USER_POOL_ID`  | Cognito User Pool ID                         | N/A           | Yes      |
| `DYNAMODB_TABLE_PREFIX` | DynamoDB table prefix                        | N/A           | Yes      |
