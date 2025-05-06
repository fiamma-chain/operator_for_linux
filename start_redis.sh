#!/bin/bash

echo "==== Starting Redis Service ===="

# Check if Redis is already running
if docker ps | grep -q redis; then
  echo "Redis is already running."
  exit 0
fi

# Check if Redis container exists but is not running
if docker ps -a | grep -q redis; then
  echo "Redis container exists but is not running. Starting it..."
  docker start redis
else
  # Run Redis in Docker
  echo "Creating and starting Redis container..."
  docker run --name redis -p 6379:6379 -d redis:latest
fi

# Verify Redis is running
if docker ps | grep -q redis; then
  echo "Redis is now running on port 6379."
else
  echo "Failed to start Redis. Please check Docker and try again."
  exit 1
fi

echo "Redis setup completed successfully."
