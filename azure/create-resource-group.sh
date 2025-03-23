#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_ROOT/.env"

echo "Creating resource group '$RESOURCE_GROUP' in location '$LOCATION'..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Resource group created successfully."
