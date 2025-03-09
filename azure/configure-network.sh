#!/usr/bin/env bash
set -e

source ../.env

echo "Configuring network security..."

NSG_NAME=$(az network nsg list --resource-group $RESOURCE_GROUP --query "[?contains(name, '${VM_NAME}')].name" -o tsv)

if [ -z "$NSG_NAME" ]; then
    echo "Error: Could not find NSG for VM '$VM_NAME'"
    exit 1
fi

echo "Opening ports for Ollama API and Web UI..."

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name "Port_${OLLAMA_PORT}_Restricted" \
  --protocol tcp --direction inbound --priority 1001 \
  --source-address-prefix $IP_ADDRESS --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range $OLLAMA_PORT \
  --access allow

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name "Port_${WEBUI_PORT}_Restricted" \
  --protocol tcp --direction inbound --priority 1002 \
  --source-address-prefix $IP_ADDRESS --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range $WEBUI_PORT \
  --access allow

echo "Network security configured successfully."
