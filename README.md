# MuchToDo Backend - Containerization & Kubernetes Deployment

## Project Overview

Production-ready containerization and Kubernetes deployment of MuchToDo Golang backend API with MongoDB and Redis caching.

**Assessment:** AltSchool Africa Month 2 - DevOps Engineering  
**Student:** Baribefe Gbara  
**Date:** December 2025

## Architecture

### Components
- Backend API: Golang application (Port 8080)
- Database: MongoDB 7.0 with persistent storage
- Cache Layer: Redis 7 Alpine
- Orchestration: Docker Compose (development) + Kubernetes (production)

### Technology Stack
- Docker & Docker Compose
- Kubernetes (Kind cluster)
- Go 1.25.1
- MongoDB 7.0
- Redis 7 Alpine

## Project Structure
```
much-to-do/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── kind-config.yaml
├── Server/MuchToDo/
│   ├── cmd/api/main.go
│   ├── internal/
│   ├── go.mod
│   └── entrypoint.sh
├── kubernetes/
│   ├── namespace.yaml
│   ├── mongodb/
│   │   ├── mongodb-secret.yaml
│   │   ├── mongodb-configmap.yaml
│   │   ├── mongodb-pvc.yaml
│   │   ├── mongodb-deployment.yaml
│   │   └── mongodb-service.yaml
│   ├── redis/
│   │   ├── redis-pvc.yaml
│   │   ├── redis-deployment.yaml
│   │   └── redis-service.yaml
│   ├── backend/
│   │   ├── backend-secret.yaml
│   │   ├── backend-configmap.yaml
│   │   ├── backend-deployment.yaml
│   │   └── backend-service.yaml
│   └── ingress.yaml
├── scripts/
│   ├── docker-build.sh
│   ├── docker-run.sh
│   ├── k8s-deploy.sh
│   └── k8s-cleanup.sh
└── evidence/
    ├── docker/
    └── kubernetes/
```

## Prerequisites

- Docker 20.10+
- docker-compose 1.29+
- kubectl 1.27+
- Kind 0.20+
- Git

## Phase 1: Docker Deployment

### Build Docker Image
```bash
# Using automation script
./scripts/docker-build.sh

# Or manually
docker build -t much-to-do_backend:latest .
```

Build details:
- Multi-stage build (golang:1.23-alpine to alpine:3.19)
- Final image size: 88.5MB
- Build time: approximately 5 minutes

### Run with Docker Compose
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend
```

### Test Endpoints
```bash
curl http://localhost:8080/
curl http://localhost:8080/ping
curl http://localhost:8080/health
```

Expected responses:
```json
{"message":"Welcome to MuchToDo API"}
{"message":"pong"}
{"cache":"ok","database":"ok"}
```

### Stop Services
```bash
docker-compose down
docker-compose down -v  # Also remove volumes
```

## Phase 2: Kubernetes Deployment

### Create Kind Cluster
```bash
kind create cluster --config kind-config.yaml
kubectl cluster-info
kubectl get nodes
```

### Load Docker Image
```bash
kind load docker-image much-to-do_backend:latest --name muchtodo-cluster
```

### Deploy to Kubernetes
```bash
# Using automation script
./scripts/k8s-deploy.sh

# Or manually
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/redis/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml
```

### Verify Deployment
```bash
kubectl get all -n muchtodo
kubectl get pods -n muchtodo -o wide
kubectl get svc -n muchtodo
kubectl get pvc -n muchtodo
```

### Access Application
```bash
# Via NodePort
curl http://localhost:30080/
curl http://localhost:30080/health
```

### Monitor Application
```bash
# View logs
kubectl logs -n muchtodo deployment/backend -f

# Describe resources
kubectl describe deployment backend -n muchtodo
kubectl describe service backend -n muchtodo
```

### Cleanup
```bash
./scripts/k8s-cleanup.sh
kind delete cluster --name muchtodo-cluster
```

## Configuration

### Environment Variables
```env
PORT=8080
MONGO_URI=mongodb://admin:supersecretpassword@mongodb:27017/muchtodo?authSource=admin
DB_NAME=muchtodo
JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION_HOURS=72
ENABLE_CACHE=true
REDIS_ADDR=redis:6379
REDIS_PASSWORD=
LOG_LEVEL=info
LOG_FORMAT=json
```

### Resource Limits

Backend Pods:
- CPU: 100m request, 200m limit
- Memory: 128Mi request, 256Mi limit
- Replicas: 2

MongoDB:
- CPU: 250m request, 500m limit
- Memory: 256Mi request, 512Mi limit
- Storage: 1Gi

Redis:
- CPU: 100m request, 200m limit
- Memory: 128Mi request, 256Mi limit
- Storage: 500Mi

## API Endpoints

### Health & Status
- GET / - Welcome message
- GET /ping - Health ping
- GET /health - Health check (MongoDB + Redis)

### User Management
- POST /api/v1/users - Create user
- GET /api/v1/users - List users
- GET /api/v1/users/:id - Get user
- PUT /api/v1/users/:id - Update user
- DELETE /api/v1/users/:id - Delete user

### Todo Management
- POST /api/v1/todos - Create todo
- GET /api/v1/todos - List todos
- GET /api/v1/todos/:id - Get todo
- PUT /api/v1/todos/:id - Update todo
- DELETE /api/v1/todos/:id - Delete todo

## Architecture Decisions

### Multi-Stage Docker Build
Reduces final image size by 90 percent (from 400MB to 88.5MB). Builder stage compiles Go code, runtime stage contains only the binary.

### Non-Root User
All containers run as non-root user (appuser:1000) for security.

### High Availability
Backend deployment uses 2 replicas for zero-downtime deployments and load distribution.

### Persistent Storage
PersistentVolumeClaims ensure data survives pod restarts. MongoDB uses 1Gi, Redis uses 500Mi.

### Resource Limits
CPU and memory limits prevent resource exhaustion and ensure fair scheduling.

### Health Probes
Liveness and readiness probes enable automatic recovery and traffic management.

### NodePort Service
NodePort on port 30080 provides simple external access in Kind cluster.

## Troubleshooting

### Docker Issues

**Problem:** Image build fails with Go version error  
**Solution:** Dockerfile uses GOTOOLCHAIN=auto to download Go 1.25.1

**Problem:** Backend cannot connect to MongoDB  
**Solution:** Check entrypoint.sh creates .env file with MONGO_URI

**Problem:** Health check fails  
**Solution:** Use wget -O - for GET request, not --spider (HEAD)

### Kubernetes Issues

**Problem:** Backend pods in CrashLoopBackOff  
**Solution:**
```bash
kind load docker-image much-to-do_backend:latest --name muchtodo-cluster
kubectl rollout restart deployment/backend -n muchtodo
```

**Problem:** Cannot access via NodePort  
**Solution:** Verify port mapping in kind-config.yaml (containerPort: 30080)

**Problem:** MongoDB connection refused  
**Solution:** Check MongoDB pod is Running before backend starts

**Problem:** Persistent volumes not binding  
**Solution:** Kind uses storageClassName: standard by default

## Monitoring

### View Logs
```bash
kubectl logs -n muchtodo deployment/backend --all-containers=true
kubectl logs -n muchtodo deployment/backend -f
kubectl logs -n muchtodo deployment/mongodb
kubectl logs -n muchtodo deployment/redis
```

### Check Resource Usage
```bash
kubectl top pods -n muchtodo
kubectl top nodes
```

### Debug Pods
```bash
kubectl exec -it -n muchtodo deployment/backend -- sh
kubectl exec -n muchtodo deployment/backend -- env
```

## Testing

### Manual Testing
```bash
# Docker environment
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com"}'

# Kubernetes environment
curl -X POST http://localhost:30080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com"}'
```

## Deployment Evidence

Screenshots available in evidence/ folder:

### Docker Phase
1. docker-build-success.png - Successful image build
2. docker-compose-status.png - All services healthy
3. docker-endpoints-test.png - API endpoint responses

### Kubernetes Phase
4. kind-cluster-info.png - Cluster information
5. kubectl-get-all.png - All resources in namespace
6. kubectl-get-pods.png - Pod details with IPs
7. kubectl-get-services.png - Service endpoints
8. kubectl-deployments.png - Deployment status
9. nodeport-access-test.png - Application via NodePort
10. backend-pod-logs.png - Backend pod logs
11. persistent-volumes.png - PVCs and PVs
12. configmaps-secrets.png - ConfigMaps and Secrets
13. service-details.png - Service description

## Security Features

1. Non-root containers - All containers run as unprivileged users
2. Secrets management - Sensitive data in Kubernetes Secrets
3. Network policies - Namespace isolation
4. Resource limits - Prevent DoS via resource exhaustion

## Author

Baribefe Gbara  
AltSchool Africa - DevOps Engineering  
GitHub: https://github.com/BaribefeGbara

## Project Status

Status: Complete  
Last Updated: December 2025 
Version: 1.0.0
