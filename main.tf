# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terraformerresourcegroup" {
  name     = "terraformerresourcegroup"
  location = "North Europe"
}

resource "azurerm_log_analytics_workspace" "trganalyticsworkspace" {
  name                = "trganalyticsworkspace"
  location            = azurerm_resource_group.terraformerresourcegroup.location
  resource_group_name = azurerm_resource_group.terraformerresourcegroup.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "trgcontainerappenvironment" {
  name                       = "trgcontainerappenvironment"
  location                   = azurerm_resource_group.terraformerresourcegroup.location
  resource_group_name        = azurerm_resource_group.terraformerresourcegroup.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.trganalyticsworkspace.id
}



resource "azurerm_container_app" "terraformercontainerapp" {
  name                         = "terraformercontainerapp"
  container_app_environment_id = azurerm_container_app_environment.trgcontainerappenvironment.id
  resource_group_name          = azurerm_resource_group.terraformerresourcegroup.name
  revision_mode                = "Single"


  ingress {
    target_port = 80
    external_enabled = true
    traffic_weight {
      percentage = 100
    }
  }

  template {
    container {
      name   = "terraformer"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}



