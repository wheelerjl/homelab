#!/usr/bin/env bash
set -euo pipefail

# This script helps set up Tandoor with the Postgres database running in Kubernetes

# Get the IP address of the Postgres pod in the Kubernetes cluster
echo "Getting Postgres pod IP address from Kubernetes..."
POD_NAME=$(kubectl get pods -n tools -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')
if [ -z "$POD_NAME" ]; then
    echo "Error: Could not find the PostgreSQL pod in the 'tools' namespace."
    echo "Make sure your PostgreSQL is running in the Kubernetes cluster."
    exit 1
fi

echo "Found PostgreSQL pod: $POD_NAME"

# Let's check if PostgreSQL is accessible from the host
echo "Testing connection to PostgreSQL..."
if ! nc -z localhost 5432; then
    echo "Warning: PostgreSQL on localhost:5432 is not accessible."
    echo "This could indicate that PostgreSQL in your Kind cluster is not properly exposed."
    echo "Check that hostNetwork: true is set in your PostgreSQL configuration."
    echo "You may need to restart your PostgreSQL pod."
    
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if .env file exists
if [ ! -f ./.env ]; then
    echo "Error: .env file not found!"
    echo "Please create a .env file with the following minimum configuration:"
    echo "SECRET_KEY=change-me-please"
    echo "DEBUG=0"
    echo "ALLOWED_HOSTS=*"
    echo "DB_ENGINE=django.db.backends.postgresql"
    echo "POSTGRES_HOST=localhost"
    echo "POSTGRES_PORT=5432"
    echo "POSTGRES_USER=postgres"
    echo "POSTGRES_PASSWORD=postgres"
    echo "POSTGRES_DB=local"
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
