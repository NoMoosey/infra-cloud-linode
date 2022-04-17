

variable "kube_config_name" {
  type        = string
  default     = "kubeconfig-linode"
  description = "The kubeconfig file to reference in this module."
}
