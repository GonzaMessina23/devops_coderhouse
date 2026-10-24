
resource "kubernetes_ingress_v1" "flask" {
  metadata {
    name      = "devops-login-ingress"
    namespace = var.namespace
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = "app.login.localhost"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.flask.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

