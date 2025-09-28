#!/bin/bash

# Environment Destruction Script
# Usage: ./destroy.sh <environment>

set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    echo "Environments: dev, staging, prod"
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

echo "🗑️  Destroying $ENVIRONMENT environment"
echo "⚠️  This will permanently delete all resources in $ENVIRONMENT"

read -p "Are you absolutely sure you want to destroy the $ENVIRONMENT environment? Type 'yes' to confirm: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Destroy cancelled"
    exit 0
fi

./deploy.sh $ENVIRONMENT destroy

echo "✅ $ENVIRONMENT environment destroyed"