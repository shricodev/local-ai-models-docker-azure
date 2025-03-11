#!/usr/bin/env bash
set -e
source ../.env
source ../.vm_details.env

if [ -n "$OLLAMA_DEFAULT_MODEL" ]; then
  echo "Running default model $OLLAMA_DEFAULT_MODEL..."
  ssh $USERNAME@$PUBLIC_IP << EOF
    sudo docker exec ollama ollama run $OLLAMA_DEFAULT_MODEL
EOF
  echo "Default model $OLLAMA_DEFAULT_MODEL run successfully."
fi

if [ -n "$OLLAMA_ADDITIONAL_MODELS" ]; then
  echo "additional models $OLLAMA_ADDITIONAL_MODELS..."
  IFS=',' read -ra MODELS <<< "$OLLAMA_ADDITIONAL_MODELS"

  for MODEL in "${MODELS[@]}"; do
    # trim whitespace
    MODEL=$(echo "$MODEL" | xargs)
    echo "Running additional model $MODEL..."
    ssh $USERNAME@$PUBLIC_IP << EOF
      sudo docker exec ollama ollama run $MODEL
EOF
    echo "Additional model $MODEL run successfully."
  done
fi

echo "All models have been processed successfully."
