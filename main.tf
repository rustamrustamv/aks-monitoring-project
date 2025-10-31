# main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-project-prod"
  location = "West Europe" 
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-cluster-prod" 

  default_node_pool {
    name       = "defaultpool"
    node_count = 3
    vm_size    = "Standard_B2s" # The VM size for the nodes
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  }
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = "la-aks-project-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}