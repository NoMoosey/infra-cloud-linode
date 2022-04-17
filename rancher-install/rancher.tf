# resource "kubectl_manifest" "cert_manager_crd_manifest" {
#   yaml_body = var.cert_mgr_manifest
# }

# resource "time_sleep" "wait_for_certmgr_crd" {
#   create_duration = "30s"
#   depends_on = [kubectl_manifest.cert_manager_crd_manifest]
# }

# resource "kubernetes_manifest" "cert_mgr_crd" {
#   manifest = yamldecode(file("${path.module}/${var.cert_mgr_crd_filename}"))
# }

resource "helm_release" "cert_manager_release" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.8.0"

  namespace = "cert-manager"
  create_namespace = true
  cleanup_on_fail = true
  recreate_pods = true
  force_update = true

  # Install Kubernetes CRDs
  set {
      name  = "installCRDs"
      value = "true"
  }    
  # depends_on = [time_sleep.wait_for_certmgr_crd]
}

resource "time_sleep" "wait_for_certmgr_release" {
  create_duration = "30s"
  depends_on = [helm_release.cert_manager_release]
}

resource "helm_release" "rancher_release" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.6.4"

  namespace = "cattle-system"
  create_namespace = true
  cleanup_on_fail = true
  recreate_pods = true
  force_update = true

  set {
    name = "hostname"
    value = "rancher.crowlight.com"
  }

  depends_on = [
    time_sleep.wait_for_certmgr_release
  ]
}

#TODO: This could be improved by looking for the app via feedback
resource "time_sleep" "wait_for_rancher_release" {
  create_duration = "30s"
  depends_on = [helm_release.rancher_release]
}

resource "kubernetes_service_v1" "rancher_lb" {
  metadata {
    name = "rancher-lb"
    namespace = helm_release.rancher_release.namespace
  }
  spec {
    selector = {
      app = "rancher"
    }
    session_affinity = "ClientIP"
    port {
      port        = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
  depends_on = [time_sleep.wait_for_rancher_release]
}

data "kubernetes_service_v1" "rancher_lb_data" {
  metadata {
    name = kubernetes_service_v1.rancher_lb.metadata.0.name
  }
}

output "rancher_ip" {
  value       = kubernetes_service_v1.rancher_lb.status.0.load_balancer.0.ingress.0.ip
  description = "Rancher is ready at this IP."
  sensitive   = false
}
