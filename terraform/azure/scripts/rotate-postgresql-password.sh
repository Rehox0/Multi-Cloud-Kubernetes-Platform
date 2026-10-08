#!/usr/bin/env bash

set -euo pipefail

KEY_VAULT_NAME="${KEY_VAULT_NAME}"
SECRET_NAME="postgresql-admin-password"
DB_SERVER="${DB_SERVER}"
RESOURCE_GROUP="${RESOURCE_GROUP}"

PASSWORD=$(openssl rand -hex 32)

trap 'unset PASSWORD' EXIT

echo "Rotating PostgreSQL administrator password..."

az postgres flexible-server update \
  --name "$DB_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --admin-password "$PASSWORD" \
  --output none

echo "Updating Key Vault secret..."

az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$SECRET_NAME" \
  --value "$PASSWORD" \
  --output none

echo "PostgreSQL password rotation completed."