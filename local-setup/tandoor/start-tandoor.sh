#!/usr/bin/env bash
set -euo pipefail

# This script helps set up Tandoor with the Postgres database running in Kubernetes

# Check if .env file exists
if [ ! -f ./.env ]; then
    echo "Error: .env file not found!"
    exit 1
fi

# Ensure the mediafiles directory exists
if [ ! -d ./mediafiles ]; then
    echo "Creating mediafiles directory..."
    mkdir -p ./mediafiles
fi

# Start Tandoor with Docker Compose
echo "Starting Tandoor with Docker Compose..."
docker compose up -d

echo "Tandoor is now starting. It will be available at http://localhost:8081"
echo "If you encounter any database connection issues, check that your .env file has the correct PostgreSQL connection settings."
