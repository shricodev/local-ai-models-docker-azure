#!/usr/bin/env bash
set -e

source ../.env
source ../.vm_details.env

echo "Deploying Docker containers to the VM..."

scp ../docker-compose.yaml $USERNAME@$PUBLIC_IP:~/ollama-project/

ssh $USERNAME@$PUBLIC_IP << 'EOF'
  cd ~/ollama-project
  export WEBUI_PORT=3000
  sudo docker-compose up -d
  echo "Docker containers started successfully."
EOF

echo "Deployment completed successfully."
echo "Web UI available at: http://$PUBLIC_IP:$WEBUI_PORT"
