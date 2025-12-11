#!/bin/bash
set -e

echo "Building Docker image for MuchToDo backend..."
docker build -t much-to-do_backend:latest .

echo ""
echo "Docker image built successfully!"
docker images | grep much-to-do
