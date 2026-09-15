data "azapi_resource" "aks_vmss" {
  type        = "Microsoft.Compute/virtualMachineScaleSets@2024-07-01"
  resource_id = var.aks_vmss_id
}