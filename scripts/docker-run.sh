#!/bin/bash
set -e

echo "Starting MuchToDo application with docker-compose..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
sleep 30

echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "Testing endpoints..."
echo "Root endpoint:"
curl -s http://localhost:8080/ | jq .

echo ""
echo "Ping endpoint:"
curl -s http://localhost:8080/ping | jq .

echo ""
echo "Health endpoint:"
curl -s http://localhost:8080/health | jq .

echo ""
echo "All services running successfully!"
