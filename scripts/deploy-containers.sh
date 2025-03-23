#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/.env"
source "$PROJECT_ROOT/.vm_details.env"

echo "Deploying Docker containers to the VM..."

scp "$PROJECT_ROOT/docker-compose.yaml" $USERNAME@$PUBLIC_IP:~/ollama-project/

ssh $USERNAME@$PUBLIC_IP << 'EOF'
  cd ~/ollama-project
  export WEBUI_PORT=3000
  sudo docker-compose up -d
  echo "Docker containers started successfully."
EOF

echo "Deployment completed successfully."
echo "Web UI available at: http://$PUBLIC_IP:$WEBUI_PORT"
