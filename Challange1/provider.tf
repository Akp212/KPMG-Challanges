terraform {
#required_version = ">=2.0.0"
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = ">=1.0.0"
}
}
}

provider "azurerm" {

features {}
}
