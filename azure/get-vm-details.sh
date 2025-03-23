#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/.env"

echo "Getting VM details..."

PUBLIC_IP=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --show-details --query publicIps -o tsv)

if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Could not retrieve public IP for VM '$VM_NAME'"
    exit 1
fi

echo "VM Public IP: $PUBLIC_IP"
echo "Ollama API endpoint: http://$PUBLIC_IP:$OLLAMA_PORT"
echo "Web UI: http://$PUBLIC_IP:$WEBUI_PORT"

echo "PUBLIC_IP=$PUBLIC_IP" > "$PROJECT_ROOT/.vm_details.env"

echo "VM details retrieved successfully."
