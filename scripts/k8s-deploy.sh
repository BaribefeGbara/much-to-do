#!/bin/bash
set -e

echo "Deploying MuchToDo to Kubernetes..."
echo ""

# Create namespace
echo "1. Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml

# Deploy MongoDB
echo ""
echo "2. Deploying MongoDB..."
kubectl apply -f kubernetes/mongodb/mongodb-secret.yaml
kubectl apply -f kubernetes/mongodb/mongodb-configmap.yaml
kubectl apply -f kubernetes/mongodb/mongodb-pvc.yaml
kubectl apply -f kubernetes/mongodb/mongodb-deployment.yaml
kubectl apply -f kubernetes/mongodb/mongodb-service.yaml

# Deploy Redis
echo ""
echo "3. Deploying Redis..."
kubectl apply -f kubernetes/redis/redis-pvc.yaml
kubectl apply -f kubernetes/redis/redis-deployment.yaml
kubectl apply -f kubernetes/redis/redis-service.yaml

# Deploy Backend
echo ""
echo "4. Deploying Backend..."
kubectl apply -f kubernetes/backend/backend-secret.yaml
kubectl apply -f kubernetes/backend/backend-configmap.yaml
kubectl apply -f kubernetes/backend/backend-deployment.yaml
kubectl apply -f kubernetes/backend/backend-service.yaml

# Deploy Ingress
echo ""
echo "5. Deploying Ingress..."
kubectl apply -f kubernetes/ingress.yaml

echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb -n muchtodo
kubectl wait --for=condition=available --timeout=300s deployment/redis -n muchtodo
kubectl wait --for=condition=available --timeout=300s deployment/backend -n muchtodo

echo ""
echo "Deployment Status:"
kubectl get all -n muchtodo

echo ""
echo "MuchToDo deployed successfully to Kubernetes!"
