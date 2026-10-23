resource "null_resource" "wait_for_gateway_pls" {
  triggers = {
    bootstrap_hash = filesha256("../../modules/jumpbox/bootstrap.sh")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      echo "Waiting for Azure Private Link Service..."

      for i in $(seq 1 50); do
        STATE=$(az network private-link-service show \
          --resource-group "${module.aks.node_resource_group}" \
          --name "${var.project_name}-gateway-pls" \
          --query "provisioningState" \
          --output tsv 2>/dev/null || true)

        if [ "$STATE" = "Succeeded" ]; then
          echo "Private Link Service is ready."
          exit 0
        fi

        echo "PLS not ready yet (state: $STATE). Attempt $i/50..."
        sleep 10
      done

      echo "ERROR: Private Link Service did not become ready within 10 minutes."
      exit 1
    EOT
  }

  depends_on = [
    module.jumpbox
  ]
}