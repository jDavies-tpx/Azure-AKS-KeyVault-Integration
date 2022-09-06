provider "azurerm" {
  features {
    # key_vault {
    #   purge_soft_delete_on_destroy = true
    # }
  }
}

data "azurerm_client_config" "current" {}

resource "random_integer" "rand-suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_key_vault" "my-aks-key-vault" {
  name                        = "${var.key_vault_name}-${random_integer.rand-suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = var.key_vault_sku
}

resource "azurerm_key_vault_access_policy" "default_access_policy" {
  key_vault_id = azurerm_key_vault.my-aks-key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions         = ["Get"]
  secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  certificate_permissions = ["Get"]
  storage_permissions     = []
}

resource "azurerm_kubernetes_cluster" "my-k8-cluster" {
  name                = "${var.aks_cluster_name}-${random_integer.rand-suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name                = var.aks_default_node_pool_name
    vm_size             = var.aks_default_node_pool_vm_size
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

}

resource "azurerm_container_registry" "my-aks-reg" {
  name                = "${var.acr_name}${random_integer.rand-suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
}

resource "azurerm_role_assignment" "aks_acr_role" {
  principal_id                     = azurerm_kubernetes_cluster.my-k8-cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.my-aks-reg.id
  skip_service_principal_aad_check = true
}

resource "azurerm_key_vault_access_policy" "aks_managed_identity_access_policy" {
  key_vault_id = azurerm_key_vault.my-aks-key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_user_assigned_identity.key-vault-managed-identity.principal_id

  key_permissions         = ["Get"]
  secret_permissions      = ["Get"]
  certificate_permissions = ["Get"]
  storage_permissions     = []
  depends_on = [
    azurerm_kubernetes_cluster.my-k8-cluster
  ]
}

data "azurerm_user_assigned_identity" "key-vault-managed-identity" {
  name                = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.my-k8-cluster.name}"
  resource_group_name = "MC_${var.resource_group_name}_${azurerm_kubernetes_cluster.my-k8-cluster.name}_${var.location}"
  depends_on = [
    azurerm_kubernetes_cluster.my-k8-cluster
  ]
}