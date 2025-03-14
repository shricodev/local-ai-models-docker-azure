#!/usr/bin/env bash
set -e

source ../.env
echo "Configuring network security..."

# Get current public IP address with fallback to .env one.
echo "Retrieving current public IP address..."
IP_ADDRESS_CURRENT=$(curl -s https://api.ipify.org || echo "")
if [ -z "$IP_ADDRESS_CURRENT" ]; then
    echo "Warning: Could not retrieve IP from api.ipify.org, falling back to .env value"
    IP_ADDRESS_CURRENT=$IP_ADDRESS
fi

echo "Using IP address: $IP_ADDRESS_CURRENT"

NSG_NAME=$(az network nsg list --resource-group $RESOURCE_GROUP --query "[?contains(name, '${VM_NAME}')].name" -o tsv)
if [ -z "$NSG_NAME" ]; then
    echo "Error: Could not find NSG for VM '$VM_NAME'"
    exit 1
fi

create_or_update_nsg_rule() {
    local RULE_NAME=$1
    local PORT=$2
    local PRIORITY=$3

    RULE_EXISTS=$(az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?name=='$RULE_NAME'].name" -o tsv)

    if [ -z "$RULE_EXISTS" ]; then
        echo "Creating new rule: $RULE_NAME for port $PORT..."
        az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
            --name "$RULE_NAME" \
            --protocol tcp --direction inbound --priority $PRIORITY \
            --source-address-prefix $IP_ADDRESS_CURRENT --source-port-range "*" \
            --destination-address-prefix "*" --destination-port-range $PORT \
            --access allow
    else
        echo "Updating existing rule: $RULE_NAME with new IP address..."
        az network nsg rule update --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
            --name "$RULE_NAME" \
            --source-address-prefix $IP_ADDRESS_CURRENT
    fi
}

# Check if 'default-allow-ssh' exists
SSH_RULE_EXISTS=$(az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?name=='default-allow-ssh'].name" -o tsv)
if [ -n "$SSH_RULE_EXISTS" ]; then
    echo "Updating existing SSH rule (default-allow-ssh) with restricted IP..."
    az network nsg rule update --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
        --name "default-allow-ssh" \
        --source-address-prefix $IP_ADDRESS_CURRENT
else
    # If no default SSH rule, create our own with a different priority
    create_or_update_nsg_rule "SSH_Restricted" 22 1010
fi

# Configure rules for Ollama and Web UI
echo "Opening ports for Ollama API and Web UI (restricted to your IP)..."

create_or_update_nsg_rule "Port_${OLLAMA_PORT}_Restricted" $OLLAMA_PORT 1001
create_or_update_nsg_rule "Port_${WEBUI_PORT}_Restricted" $WEBUI_PORT 1002

echo "Network security configured successfully."
echo "Note: If your IP address changes, you'll need to run this script again to update the rules."
