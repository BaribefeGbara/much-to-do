#!/bin/bash
set -e

echo "Cleaning up MuchToDo from Kubernetes..."
echo ""

# Delete in reverse order
echo "1. Deleting Ingress..."
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found=true

echo ""
echo "2. Deleting Backend..."
kubectl delete -f kubernetes/backend/backend-service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-configmap.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-secret.yaml --ignore-not-found=true

echo ""
echo "3. Deleting Redis..."
kubectl delete -f kubernetes/redis/redis-service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/redis/redis-deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/redis/redis-pvc.yaml --ignore-not-found=true

echo ""
echo "4. Deleting MongoDB..."
kubectl delete -f kubernetes/mongodb/mongodb-service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-pvc.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-configmap.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-secret.yaml --ignore-not-found=true

echo ""
echo "5. Deleting Namespace..."
kubectl delete -f kubernetes/namespace.yaml --ignore-not-found=true

echo ""
echo "Cleanup completed!"
