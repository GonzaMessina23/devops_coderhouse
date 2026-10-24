
resource "kubernetes_config_map_v1" "app" {
  metadata {
    name      = "devops-login-config"
    namespace = var.namespace
  }

  data = {
    POSTGRES_HOST = "postgres"
    POSTGRES_PORT = "5432"
    POSTGRES_DB   = "login_db"
    POSTGRES_USER = "login_user"
  }
}

resource "kubernetes_service_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "flask" {
  metadata {
    name      = "devops-login-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "devops-login"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "ClusterIP"
  }
}

