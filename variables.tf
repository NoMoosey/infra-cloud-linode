locals {
    # The token is defined in the 'configs' repo for obscurity.
    # This repo needs to be present in the parent directory.
    linode_token = yamldecode(file("../configs/cloud/linode.yaml"))["token"]
}

variable "kube_config_name" {
  type        = string
  default     = "kubeconfig-linode"
  description = "The kubeconfig file to reference in this module."
}
