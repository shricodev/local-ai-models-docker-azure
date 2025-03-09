#!/usr/bin/env bash
set -e

source ../.env

echo "Creating resource group '$RESOURCE_GROUP' in location '$LOCATION'..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Resource group created successfully."
