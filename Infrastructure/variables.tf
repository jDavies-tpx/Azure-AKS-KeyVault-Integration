#Globals
variable "location" {
  type    = string
  default = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "aks-keyvault-integration"
}

#Key Vault
variable "key_vault_name"{
    type = string
    default = "my-aks-key-vault"
}

variable "key_vault_sku"{
    type = string
    default = "standard"
}

#K8 Cluster
variable "aks_cluster_name" {
  type = string
  default = "my-k8-cluster"
}

variable "aks_default_node_pool_name"{
    type = string
    default = "agentpool"
}

variable "aks_default_node_pool_vm_size"{
    type = string
    default = "Standard_D2as_v5"
}

#Azure Container Registry
variable "acr_name" {
  type = string
  default = "myaksreg"
}

variable "acr_sku"{
    type = string
    default = "Basic"
}
