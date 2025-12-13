# MuchTodo - Containerized Backend Application

A modern Go backend application deployed with Docker and Kubernetes, demonstrating production-ready containerization and orchestration practices.

## Table of Contents

- [About This Project](#about-this-project)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Testing Your Deployment](#testing-your-deployment)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

## About This Project

MuchTodo is a containerized Go backend API deployed on Kubernetes with MongoDB for data persistence. This project demonstrates how to take a traditional server-based application and modernize it using containers and orchestration tools.

**What This Project Includes:**
- Go 1.25 REST API running on port 8080
- MongoDB 7.0 database with persistent storage
- Docker setup with multi-stage build (reduces image size by 85%)
- Kubernetes deployment with 2 backend replicas for high availability
- Automated deployment scripts for easy setup
- Health monitoring and self-healing capabilities

**Why These Technologies:**
- **Docker** packages your application with all dependencies, making it run the same everywhere
- **Kubernetes** automatically manages your containers, scales them, and restarts them if they crash
- **Multi-stage builds** keep your final Docker image small and secure
- **Persistent storage** ensures your data survives even when containers restart

## Prerequisites

Before starting, you need these tools installed on your computer. Think of these as the foundation that everything else builds on top of.

### Required Tools

**Docker Desktop** (v20.10 or higher)
- This lets you run containers on your local machine
- Download from: https://www.docker.com/products/docker-desktop
- Includes both Docker and Docker Compose

**Kind** (Kubernetes in Docker, v0.20.0+)
- Creates a local Kubernetes cluster for testing
- Runs entirely inside Docker containers
- Installation:
  ```bash
  # macOS
  brew install kind
  
  # Linux
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  
  # Windows (PowerShell)
  curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
  Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
  ```

**kubectl** (v1.24+)
- Command-line tool for talking to Kubernetes
- Installation guide: https://kubernetes.io/docs/tasks/tools/

**Git**
- For version control
- Download from: https://git-scm.com/downloads

### Verify Your Installation

Run these commands to make sure everything is installed correctly:

```bash
docker --version          # Should show v20.10 or higher
docker-compose --version  # Should show compose version
kind --version           # Should show v0.20.0 or higher
kubectl version --client # Should show v1.24 or higher
git --version           # Should show git version
```

If any command doesn't work, go back and install that tool before continuing.

## Project Structure

Understanding where everything lives in the project helps you navigate and make changes. Here's what each folder contains:

```
muchtodo/
├── cmd/
│   └── api/
│       └── main.go                    # Your Go application entry point
│
├── docker/
│   ├── Dockerfile                     # Instructions for building Docker image
│   ├── docker-compose.yml             # Defines all services for local dev
│   └── .dockerignore                  # Files to exclude from Docker build
│
├── kubernetes/
│   ├── namespace.yaml                 # Creates isolated environment in K8s
│   │
│   ├── mongodb/                       # Everything MongoDB needs
│   │   ├── mongodb-secret.yaml        # Database passwords (encrypted)
│   │   ├── mongodb-configmap.yaml     # Database configuration settings
│   │   ├── mongodb-pvc.yaml           # Requests storage for data
│   │   ├── mongodb-deployment.yaml    # How to run MongoDB
│   │   └── mongodb-service.yaml       # Network endpoint for database
│   │
│   ├── backend/                       # Everything your API needs
│   │   ├── backend-secret.yaml        # Application secrets
│   │   ├── backend-configmap.yaml     # Application configuration
│   │   ├── backend-deployment.yaml    # How to run your API
│   │   └── backend-service.yaml       # Network endpoint for API
│   │
│   └── ingress.yaml                   # Routes external traffic to your app
│
├── scripts/                           # Automation makes life easier
│   ├── docker-build.sh                # Builds your Docker image
│   ├── docker-run.sh                  # Starts everything with Docker Compose
│   ├── k8s-deploy.sh                  # Deploys to Kubernetes
│   └── k8s-cleanup.sh                 # Removes all Kubernetes resources
│
├── evidence/                          # Screenshots proving it works
└── README.md                          # You are here!
```

## Quick Start

Want to see it running immediately? Follow these steps:

### Option 1: Using Docker Compose (Easiest for Local Development)

Docker Compose starts both your backend and MongoDB with a single command:

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd muchtodo

# 2. Make scripts executable (only needed once)
chmod +x scripts/*.sh

# 3. Build the Docker image
./scripts/docker-build.sh

# 4. Start everything (backend + MongoDB)
./scripts/docker-run.sh

# 5. Test it's working
curl http://localhost:8080/health
```

You should see a response like: `{"status":"healthy","database":"connected"}`

### Option 2: Using Kubernetes (More Production-Like)

Kubernetes gives you the full orchestration experience:

```bash
# 1. Create a local Kubernetes cluster
kind create cluster --name muchtodo-cluster

# 2. Deploy everything
./scripts/k8s-deploy.sh

# 3. Forward the port to access the app
kubectl port-forward -n go-backend-ns svc/backend-service 8080:80

# 4. Test it (open a new terminal)
curl http://localhost:8080/health
```

## Docker Deployment

Docker packages your application into a container that includes everything it needs to run. This section covers how to build and run your application using Docker.

### Understanding the Dockerfile

The `Dockerfile` is like a recipe that tells Docker how to build your application. We use a **multi-stage build** which works in two phases:

1. **Build Stage**: Uses a full Go environment to compile your code
2. **Runtime Stage**: Copies only the compiled binary to a minimal image

**Why this matters:** The final image is about 15MB instead of 1.2GB - that's 85% smaller! Smaller images download faster, use less storage, and have fewer security vulnerabilities.

### Building the Docker Image

```bash
# This reads your Dockerfile and creates an image
./scripts/docker-build.sh
```

**What's happening behind the scenes:**
- Downloads the base Go image
- Copies your source code
- Compiles your Go application
- Creates a final minimal image with just the binary
- Tags it as "muchtodo-backend:latest"

### Running with Docker Compose

Docker Compose lets you run multiple containers together. For this project, you need both the backend API and MongoDB database.

```bash
# Start all services
./scripts/docker-run.sh
```

**What this does:**
- Starts MongoDB in its own container
- Waits for MongoDB to be ready
- Starts your backend API
- Connects them on a private network
- Makes your API available at localhost:8080

### Useful Docker Commands

```bash
# See what's running
docker ps

# View backend logs (helpful for debugging)
docker-compose -f docker/docker-compose.yml logs -f backend

# View MongoDB logs
docker-compose -f docker/docker-compose.yml logs -f mongodb

# Stop everything
docker-compose -f docker/docker-compose.yml down

# Stop and delete all data (fresh start)
docker-compose -f docker/docker-compose.yml down -v
```

### Testing Your Docker Setup

```bash
# Basic health check
curl http://localhost:8080/health

# Simple ping test
curl http://localhost:8080/ping

# Check if MongoDB is accessible from backend
docker exec -it muchtodo-backend ping mongodb
```

## Kubernetes Deployment

Kubernetes (K8s) is like an automated operations team for your containers. It makes sure your application stays running, scales it when needed, and recovers from failures automatically.

### Why Use Kubernetes?

Think of Kubernetes as a smart manager that:
- Keeps your application running (restarts it if it crashes)
- Runs multiple copies for reliability (we use 2 backend replicas)
- Distributes traffic across all copies
- Provides persistent storage that survives restarts
- Makes updates without downtime

### Understanding Kubernetes Components

Before deploying, let's understand what each Kubernetes resource does:

**Namespace** - Like a folder that keeps your app separate from others

**Secret** - Stores sensitive data (passwords, API keys) in an encrypted way

**ConfigMap** - Stores configuration (non-sensitive settings) that can be changed without rebuilding

**PersistentVolumeClaim (PVC)** - Requests storage space for your data (MongoDB needs this)

**Deployment** - Tells Kubernetes how to run your app (how many copies, what image, health checks)

**Service** - Creates a stable network address for your app (like a phone number that doesn't change)

**Ingress** - Routes traffic from outside the cluster to your services (like a receptionist directing visitors)

### Step 1: Create a Kubernetes Cluster

Kind creates a mini Kubernetes cluster on your computer using Docker:

```bash
# Create the cluster (takes a minute or two)
kind create cluster --name muchtodo-cluster

# Verify it's working
kubectl cluster-info --context kind-muchtodo-cluster
```

**What just happened?** Kind created several Docker containers that work together to simulate a real Kubernetes cluster. You can now deploy applications to it just like you would in production.

### Step 2: Deploy Your Application

```bash
# Deploy everything with one command
./scripts/k8s-deploy.sh
```

**What this script does step-by-step:**
1. Creates a namespace called "go-backend-ns" (your app's isolated space)
2. Deploys MongoDB with persistent storage
3. Deploys your backend API (2 copies for reliability)
4. Creates services so components can talk to each other
5. Sets up ingress for external access
6. Waits for everything to be ready

### Step 3: Verify the Deployment

```bash
# Check if all pods are running
kubectl get pods -n go-backend-ns

# You should see something like:
# NAME                                  READY   STATUS    RESTARTS   AGE
# backend-deployment-xxxx               1/1     Running   0          2m
# backend-deployment-yyyy               1/1     Running   0          2m
# mongodb-0                             1/1     Running   0          2m

# Check all resources at once
kubectl get all -n go-backend-ns
```

**Understanding the output:**
- `READY 1/1` means the container is running successfully
- `STATUS Running` means everything is working
- `RESTARTS 0` means it hasn't crashed (low number is good)
- You should see 2 backend pods and 1 MongoDB pod

### Step 4: Access Your Application

**Method 1: Port Forwarding (Easiest)**

This connects your local port 8080 to the Kubernetes service:

```bash
kubectl port-forward -n go-backend-ns svc/backend-service 8080:80

# Now you can access it at http://localhost:8080
# Open a new terminal and test:
curl http://localhost:8080/health
```

**Method 2: NodePort (Direct Access)**

If your backend service uses NodePort type:

```bash
# Find the NodePort (usually 30000-32767)
kubectl get svc -n go-backend-ns backend-service

# Access at http://localhost:<NODEPORT>
```

### Useful Kubernetes Commands

```bash
# View logs from a specific pod
kubectl logs -n go-backend-ns <pod-name>

# Follow logs in real-time (like tail -f)
kubectl logs -n go-backend-ns <pod-name> -f

# View logs from all backend pods
kubectl logs -n go-backend-ns -l app=backend

# Get detailed info about a pod (shows events and errors)
kubectl describe pod -n go-backend-ns <pod-name>

# Open a shell inside a pod (for debugging)
kubectl exec -it -n go-backend-ns <pod-name> -- /bin/sh

# Scale your backend (change number of replicas)
kubectl scale deployment backend-deployment -n go-backend-ns --replicas=3

# Check resource usage
kubectl top pods -n go-backend-ns
```

### Cleaning Up

When you're done testing or want to start fresh:

```bash
# Remove all Kubernetes resources
./scripts/k8s-cleanup.sh

# Delete the entire cluster
kind delete cluster --name muchtodo-cluster
```

## Testing Your Deployment

Testing ensures everything is working correctly. Here's how to test both Docker and Kubernetes deployments.

### API Endpoints

Your application exposes these endpoints:

```bash
# Health check - shows if app and database are connected
curl http://localhost:8080/health
# Response: {"status":"healthy","database":"connected","timestamp":"..."}

# Ping - simple connectivity test
curl http://localhost:8080/ping
# Response: {"message":"pong"}
```

### Testing Docker Deployment

```bash
# 1. Check containers are running
docker ps
# Should show both muchtodo-backend and muchtodo-mongodb

# 2. Test the health endpoint
curl http://localhost:8080/health

# 3. Check backend logs for errors
docker logs muchtodo-backend

# 4. Verify MongoDB is accessible
docker exec -it muchtodo-mongodb mongosh --eval "db.adminCommand('ping')"
# Response should show {ok: 1}

# 5. Test the network between containers
docker exec muchtodo-backend ping -c 3 mongodb
# Should show successful ping responses
```

### Testing Kubernetes Deployment

```bash
# 1. Check all pods are running
kubectl get pods -n go-backend-ns
# All should show STATUS: Running and READY: 1/1

# 2. Set up port forwarding
kubectl port-forward -n go-backend-ns svc/backend-service 8080:80

# 3. Test the health endpoint (in a new terminal)
curl http://localhost:8080/health

# 4. Check pod logs for errors
kubectl logs -n go-backend-ns <backend-pod-name>

# 5. Verify MongoDB is working
kubectl exec -it -n go-backend-ns mongodb-0 -- mongosh --eval "db.adminCommand('ping')"

# 6. Test scaling (optional)
kubectl scale deployment backend-deployment -n go-backend-ns --replicas=3
kubectl get pods -n go-backend-ns
# Should now show 3 backend pods
```

## Troubleshooting

Problems happen to everyone. Here's how to fix the most common issues.

### Docker Issues

**Problem: "Cannot connect to Docker daemon"**

This means Docker isn't running.

Solution:
```bash
# Make sure Docker Desktop is open and running
# On macOS/Windows: Check your applications menu
# On Linux: Start Docker service
sudo systemctl start docker
```

**Problem: "Port 8080 is already in use"**

Something else is using port 8080.

Solution:
```bash
# Find what's using the port
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Either:
# 1. Kill that process, or
# 2. Change the port in docker-compose.yml to 8081:8080
```

**Problem: "Backend can't connect to MongoDB"**

Network or timing issue between containers.

Solution:
```bash
# Check if MongoDB container is running
docker ps | grep mongodb

# View MongoDB logs for errors
docker-compose -f docker/docker-compose.yml logs mongodb

# Test network connectivity
docker exec muchtodo-backend ping mongodb

# If still failing, restart everything
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml up -d
```

### Kubernetes Issues

**Problem: Pod shows "CrashLoopBackOff"**

The pod keeps crashing and restarting.

Solution:
```bash
# Check what's causing the crash
kubectl logs -n go-backend-ns <pod-name>

# Look at recent events
kubectl describe pod -n go-backend-ns <pod-name>

# Common causes and fixes:
# - Wrong environment variables: Check ConfigMap
# - Missing secrets: Verify secrets exist
# - Application error: Check logs for stack traces
```

**Problem: Pod stuck in "Pending" state**

Kubernetes can't schedule the pod.

Solution:
```bash
# See why it's pending
kubectl describe pod -n go-backend-ns <pod-name>

# Common causes:
# - Insufficient resources: Check if Kind cluster has enough memory
# - PVC not bound: Check storage with `kubectl get pvc -n go-backend-ns`
```

**Problem: "Can't access application in browser"**

Service or networking issue.

Solution:
```bash
# 1. Verify pods are running
kubectl get pods -n go-backend-ns

# 2. Check if service exists
kubectl get svc -n go-backend-ns

# 3. Make sure port-forward is running
kubectl port-forward -n go-backend-ns svc/backend-service 8080:80

# 4. Test from inside the cluster
kubectl run -it --rm debug --image=alpine --restart=Never -n go-backend-ns -- sh
# Then inside the pod: wget -qO- http://backend-service/health
```

**Problem: PersistentVolumeClaim stuck "Pending"**

Storage isn't being provisioned.

Solution:
```bash
# Check PVC status
kubectl describe pvc -n go-backend-ns mongodb-pvc

# For Kind, ensure storage provisioner exists
kubectl get pods -n kube-system | grep storage

# If needed, delete and recreate
kubectl delete pvc -n go-backend-ns mongodb-pvc
./scripts/k8s-deploy.sh
```

### General Debugging Tips

1. **Always check logs first** - They usually tell you what's wrong
   ```bash
   # Docker
   docker logs <container-name>
   
   # Kubernetes
   kubectl logs -n go-backend-ns <pod-name>
   ```

2. **Look at events** - Shows what Kubernetes is doing
   ```bash
   kubectl get events -n go-backend-ns --sort-by='.lastTimestamp'
   ```

3. **Verify resources exist**
   ```bash
   kubectl get all -n go-backend-ns
   kubectl get secrets -n go-backend-ns
   kubectl get configmaps -n go-backend-ns
   ```

4. **Start fresh if needed**
   ```bash
   # Docker
   docker-compose -f docker/docker-compose.yml down -v
   docker-compose -f docker/docker-compose.yml up -d
   
   # Kubernetes
   ./scripts/k8s-cleanup.sh
   ./scripts/k8s-deploy.sh
   ```

## Technical Details

This section explains the technical decisions and configurations used in the project.

### Docker Multi-Stage Build

The Dockerfile uses two stages to create an optimized image:

**Stage 1: Build**
```dockerfile
FROM golang:1.25-alpine AS builder
# Includes full Go compiler and tools
# Compiles the application binary
```

**Stage 2: Runtime**
```dockerfile
FROM alpine:latest
# Only includes the compiled binary
# No build tools or source code
```

**Results:**
- Build stage: ~1.2GB (includes everything for compilation)
- Final stage: ~15MB (only what's needed to run)
- Size reduction: 85%

**Security benefits:**
- Runs as non-root user
- Minimal attack surface (fewer packages = fewer vulnerabilities)
- No build tools in production image

### Kubernetes Resource Configuration

**Resource Requests and Limits**

These tell Kubernetes how much CPU and memory your app needs:

```yaml
resources:
  requests:              # Minimum guaranteed resources
    memory: "128Mi"
    cpu: "100m"         # 0.1 CPU core
  limits:               # Maximum allowed resources
    memory: "256Mi"
    cpu: "200m"         # 0.2 CPU core
```

**Why this matters:** Prevents one app from consuming all cluster resources.

**Health Probes**

Kubernetes uses these to check if your app is healthy:

```yaml
livenessProbe:          # Is the app alive?
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  # If this fails, Kubernetes restarts the pod

readinessProbe:         # Is the app ready for traffic?
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  # If this fails, Kubernetes stops sending traffic
```

**Storage Configuration**

MongoDB uses persistent storage to keep data even when pods restart:

```yaml
PersistentVolumeClaim:
  storage: 10Gi         # Requests 10GB of storage
  accessModes:
    - ReadWriteOnce     # One pod can read/write at a time
```

### Configuration Management

**Environment Variables (Backend):**
- `PORT`: 8080 (API server port)
- `MONGODB_URI`: mongodb://mongodb:27017 (database connection)
- `DB_NAME`: muchtodo (database name)

**Secrets (Encrypted Storage):**
- MongoDB username and password
- Backend API keys or tokens
- Base64 encoded in YAML files
- Mounted as environment variables in pods

**ConfigMaps (Non-Sensitive Config):**
- Database configuration options
- Application settings
- Can be updated without rebuilding images

### Deployment Architecture

**High-Level Overview:**

```
Internet
    ↓
Ingress (routing)
    ↓
Backend Service (load balancer)
    ↓
├── Backend Pod 1 ────→ MongoDB Service
└── Backend Pod 2 ────→      ↓
                         MongoDB Pod
                             ↓
                    Persistent Storage
```

**Component Breakdown:**

| Component | Type | Replicas | Purpose |
|-----------|------|----------|---------|
| MongoDB | StatefulSet | 1 | Database with persistent identity |
| Backend | Deployment | 2 | API servers (load balanced) |
| MongoDB Service | ClusterIP | - | Stable endpoint for database |
| Backend Service | NodePort | - | External access to API |
| PersistentVolume | Storage | - | Keeps MongoDB data |

## Deployment Evidence

The `evidence/` folder contains screenshots documenting the successful deployment:

**Docker Evidence:**
- Docker build process completing successfully
- Docker Compose showing both containers running
- Health endpoint returning healthy status
- Docker logs showing no errors

**Kubernetes Evidence:**
- Kind cluster creation output
- All pods in Running state
- Services properly configured
- Ingress routing working
- Application accessible via NodePort
- kubectl commands showing healthy deployment


---

**MuchTodo** - A containerized Go backend demonstrating modern DevOps practices with Docker and Kubernetes.
