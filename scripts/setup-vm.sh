#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/.env"
source "$PROJECT_ROOT/.vm_details.env"

echo "public ip is $PUBLIC_IP"
echo "Setting up VM with Docker and dependencies..."

ssh $USERNAME@$PUBLIC_IP << 'EOF'
  # Install Docker Engine
  echo "Installing Docker..."

  # From Docker documentation for debian based distros
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  # End of docker debian installation instructions

  sudo usermod -aG docker $USER

  sudo apt-get install -y docker-compose

  sudo systemctl start docker.service

  sudo docker volume create ollama_data

  # Here we will place our docker-compose.yaml file
  mkdir -p ~/ollama-project
EOF

echo "VM setup completed successfully."
