#!/usr/bin/env bash

set -e

IMAGE_NAME="cloud-deploy-api"
CONTAINER_NAME="cloud-deploy-api"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Run the container in detached mode
docker run -d --name $CONTAINER_NAME \
  -p 8080:8080 \
  $IMAGE_NAME

# Wait for the app to start up (adjust if needed)
echo "Waiting for the app to start..."
sleep 7

# Call the endpoint and capture HTTP status code
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET http://localhost:8080/test-egress \
  -H "Content-Type: application/json")

echo "Received HTTP status: $STATUS"

# Stop the container
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

# Check if status is 200
if [ "$STATUS" -eq 200 ]; then
  echo "Health check passed, pushing image..."
  
  # Example: tag and push to Docker Hub (adjust to your cloud registry)
  docker tag $IMAGE_NAME zechary/$IMAGE_NAME:latest
  docker push zechary/$IMAGE_NAME:latest
  
  echo "Image pushed successfully."
else
  echo "Health check failed, exiting."
  exit 1
fi
