resource "linode_lke_cluster" "cluster" {
    label       = "moose-cloud-cluster"
    k8s_version = "1.23"
    region      = "ca-central"
    tags        = ["prod"]

    pool {
        type  = "g6-standard-4"
        count = 3
    }
}

# Store and source the resulting kubeconfig
resource "local_file" "kubeconfig-local" {
    content = base64decode(linode_lke_cluster.cluster.kubeconfig)
    filename = "${path.module}/kubeconfig-linode"
}

# resource "local_file" "kubeconfig-kube" {
#     content = base64decode(linode_lke_cluster.cluster.kubeconfig)
#     filename = pathexpand("~/.kube/kubeconfig-linode")
# }

resource "null_resource" "config_copy" {
  provisioner "local-exec" {
    command = "cp ${local_file.kubeconfig-local.filename} ${pathexpand("~/.kube")}"
  }
}

resource "local_file" "terraform_zsh_env" {
    content = "export KUBECONFIG=${pathexpand("~/.kube")}/${basename(local_file.kubeconfig-local.filename)}"
    filename = pathexpand("~/.terraform_env")
}

# Network config:
resource "linode_firewall" "firewall" {
  label = "moose-cloud-cluster-fw"

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-all-TCP"
    action   = "ACCEPT"
    protocol = "TCP"
    ipv4     = ["97.107.60.94/32"]
  }

  inbound {
    label    = "allow-all-UDP"
    action   = "ACCEPT"
    protocol = "UDP"
    ipv4     = ["97.107.60.94/32"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

#   for_each = linode_lke_cluster.cluster.pool[0].nodes

#   linodes = each.key

#   count = length(linode_lke_cluster.cluster.pool[0].nodes)

#   linodes = [linode_lke_cluster.cluster.pool[0].nodes[0].id]
}

resource "time_sleep" "wait_for_cluster" {
  
  create_duration = "200s"

  depends_on = [
    linode_lke_cluster.cluster
  ]

}

module "rancher" {
    source = "./rancher-install"
    depends_on = [
        time_sleep.wait_for_cluster,
        linode_firewall.firewall
    ]
}

output "rancher_ip" {
  value       = module.rancher.rancher_ip
  description = "Rancher is ready at this IP."
  sensitive   = false
}