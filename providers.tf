terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      # version = "..."
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.kube_config_name}"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/${var.kube_config_name}"
}

# Configure the Linode Provider
provider "linode" {
  token = local.linode_token
}