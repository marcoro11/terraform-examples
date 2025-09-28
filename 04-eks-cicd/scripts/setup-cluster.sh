#!/bin/bash

set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}

echo "🚀 Setting up EKS cluster: $CLUSTER_NAME in region: $REGION"

echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "✅ Verifying cluster access..."
kubectl get nodes

echo "📦 Installing additional tools..."
echo "🎉 Cluster setup complete!"
echo ""
echo "Useful commands:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"
echo "  kubectl cluster-info"
echo ""
echo "Access URLs:"
echo "  ArgoCD: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "  Grafana: kubectl port-forward -n monitoring svc/grafana 3000:80"
echo "  Prometheus: kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"