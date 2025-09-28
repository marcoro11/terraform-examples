#!/bin/bash

# Usage: ./deploy.sh <environment> [action]
# Actions: plan, apply, destroy, output

set -e

ENVIRONMENT=$1
ACTION=${2:-apply}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment> [action]"
    echo "Environments: dev, staging, prod"
    echo "Actions: plan, apply, destroy, output"
    exit 1
fi

case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        echo "Valid environments: dev, staging, prod"
        exit 1
        ;;
esac

case $ACTION in
    plan|apply|destroy|output)
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Valid actions: plan, apply, destroy, output"
        exit 1
        ;;
esac

TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"
WORKSPACE_NAME=$ENVIRONMENT

echo "🚀 Deploying to $ENVIRONMENT environment"
echo "📁 Terraform vars file: $TFVARS_FILE"
echo "🏗️  Action: $ACTION"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "❌ Error: $TFVARS_FILE not found"
    exit 1
fi

echo "📦 Initializing Terraform..."
terraform init

if terraform workspace list | grep -q "^[* ]*$WORKSPACE_NAME$"; then
    echo "🔄 Selecting workspace: $WORKSPACE_NAME"
    terraform workspace select $WORKSPACE_NAME
else
    echo "🆕 Creating workspace: $WORKSPACE_NAME"
    terraform workspace new $WORKSPACE_NAME
fi

case $ACTION in
    plan)
        echo "📋 Planning deployment..."
        terraform plan -var-file="$TFVARS_FILE"
        ;;
    apply)
        echo "✅ Applying deployment..."
        terraform apply -var-file="$TFVARS_FILE" -auto-approve
        echo "📊 Getting outputs..."
        terraform output
        ;;
    destroy)
        echo "🗑️  Destroying environment..."
        read -p "Are you sure you want to destroy the $ENVIRONMENT environment? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Destroy cancelled"
            exit 0
        fi
        terraform destroy -var-file="$TFVARS_FILE" -auto-approve
        ;;
    output)
        echo "📊 Getting outputs..."
        terraform output
        ;;
esac

echo "🎉 Done!"