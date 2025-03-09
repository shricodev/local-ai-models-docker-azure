#!/usr/bin/env bash
set -e

source ../.env

echo "Configuring security restrictions for VM..."

# Get current public IP if not specified
if [ "$IP_ADDRESS" = "0.0.0.0/0" ]; then
    echo "Warning: No specific IP address set for security restrictions."
    echo "Fetching your current public IP address..."
    CURRENT_IP=$(curl -s https://api.ipify.org)

    if [ -n "$CURRENT_IP" ]; then
        echo "Your current public IP is: $CURRENT_IP"
        read -p "Do you want to restrict access to this IP only? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            IP_ADDRESS="$CURRENT_IP/32"
            sed -i "s/IP_ADDRESS=.*/IP_ADDRESS=\"$IP_ADDRESS\"/" .env
            echo "Updated .env with your IP: $IP_ADDRESS"
        fi
    else
        echo "Could not determine your public IP. Using no restrictions."
    fi
fi

validate_ip() {
    local ip=$1
    local stat=1

    # Check if it's "0.0.0.0/0" for all IPs
    if [[ "$ip" == "0.0.0.0/0" ]]; then
        return 0
    fi

    # Extract IP without CIDR if present
    if [[ "$ip" == */* ]]; then
        local cidr="${ip#*/}"
        ip="${ip%/*}"
        # Check if CIDR is valid (0-32)
        if ! [[ "$cidr" =~ ^[0-9]+$ ]] || [ "$cidr" -lt 0 ] || [ "$cidr" -gt 32 ]; then
            return 1
        fi
    fi

    # Check IP format (xxx.xxx.xxx.xxx)
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        stat=0
    fi
    return $stat
}

# Validate and fix IP_ADDRESS if needed
if ! validate_ip "$IP_ADDRESS"; then
    echo "Warning: Invalid IP address format: $IP_ADDRESS"
    echo "Defaulting to allow all IPs (0.0.0.0/0)"
    IP_ADDRESS="0.0.0.0/0"
fi

# Get the NSG of the VM
NSG_NAME=$(az network nsg list --resource-group $RESOURCE_GROUP --query "[?contains(name, '${VM_NAME}')].name" -o tsv)

# Only allow the user IP to access
echo "Updating NSG rules to restrict access to $IP_ADDRESS..."
az network nsg rule update --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name "Port_${OLLAMA_PORT}_Restricted" --source-address-prefix $IP_ADDRESS

az network nsg rule update --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name "Port_${WEBUI_PORT}_Restricted" --source-address-prefix $IP_ADDRESS

echo "The VM Security Rules updated successfully ."
