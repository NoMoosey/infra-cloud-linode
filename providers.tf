terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      # version = "..."
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  cloud {
    organization = "crowlight"

    workspaces {
      name = "testing"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/${var.kube_config_name}"
  }
}

provider "kubernetes" {
  config_path    = "${path.module}/${var.kube_config_name}"
}

# Configure the Linode Provider
variable "linode_token" {
  default = ""
  sensitive = true
}
provider "linode" {
  token = var.linode_token
}

provider "kubectl" {
  config_path = "${path.module}/${var.kube_config_name}"
}