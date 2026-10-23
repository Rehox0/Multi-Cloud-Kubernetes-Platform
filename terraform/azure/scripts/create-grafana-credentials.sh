#!/usr/bin/env bash

set -euo pipefail

KEY_VAULT_NAME="${KEY_VAULT_NAME}"

SECRET_USER="grafana-admin-user"
SECRET_PASSWORD="grafana-admin-password"

GRAFANA_USER="admin"
GRAFANA_PASSWORD=$(openssl rand -hex 32)

trap 'unset GRAFANA_PASSWORD' EXIT

echo "Creating Grafana administrator credentials..."

az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$SECRET_USER" \
  --value "$GRAFANA_USER" \
  --output none

az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$SECRET_PASSWORD" \
  --value "$GRAFANA_PASSWORD" \
  --output none

echo "Grafana administrator credentials stored in Key Vault."