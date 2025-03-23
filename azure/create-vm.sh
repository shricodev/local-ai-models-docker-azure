#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/.env"

VM_EXISTS=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "name" -o tsv 2>/dev/null || echo "")

if [ -n "$VM_EXISTS" ]; then
    echo "VM '$VM_NAME' already exists in resource group '$RESOURCE_GROUP'."
    echo "Please choose a different VM name or use the existing VM."
    exit 1
fi

echo "Creating VM '$VM_NAME'..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --admin-username $USERNAME \
  --generate-ssh-keys \
  --size $VM_SIZE \
  --public-ip-sku Standard

# TODO: Add the generated SSH key to the ssh agent. id_rsa is the default name it comes
# with. I need to figure out how to name it differently.
# What if the user already has one in there called id_rsa?
ssh-add ~/.ssh/id_rsa

echo "VM created successfully."
