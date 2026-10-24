
resource "kubernetes_deployment_v1" "flask" {
  metadata {
    name      = "devops-login"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "devops-login"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops-login"
        }
      }

      spec {
        container {
          name              = "devops-login"
          image             = "ghcr.io/gonzamessina23/devops_coderhouse:latest"
          image_pull_policy = "Always"

          port {
            container_port = 5000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = "devops-login-secret"
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }

            initial_delay_seconds = 15
            period_seconds        = 15
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_stateful_set_v1.postgres,
    kubernetes_service_v1.flask
  ]
}

