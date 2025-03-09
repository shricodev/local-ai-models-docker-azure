#!/usr/bin/env bash
set -e

source ../.env
source ../.vm_details.env

echo "Pulling and Running Ollama model specified..."

echo "Waiting for Ollama service to initialize..."

# Adding this cuz let's give the service a few seconds to start at least
sleep 10

MODEL=${1:-$OLLAMA_DEFAULT_MODEL}

ssh $USERNAME@$PUBLIC_IP << EOF
  echo "Pulling model $MODEL..."
  sudo docker exec ollama ollama run $MODEL
EOF

echo "Model $MODEL run successfully."
