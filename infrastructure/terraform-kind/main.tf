resource "local_file" "kind_config" {
  filename = "${path.module}/cluster-generated.yaml"

  content = yamlencode({
    kind       = "Cluster"
    apiVersion = "kind.x-k8s.io/v1alpha4"
    name       = var.cluster_name

    nodes = [
      {
        role = "control-plane"

        extraPortMappings = [
          {
            containerPort = 80
            hostPort      = var.http_port
            protocol      = "TCP"
          }
        ]
      }
    ]
  })
}

resource "terraform_data" "kind_cluster" {
  triggers_replace = [
    local_file.kind_config.content_sha256
  ]

  provisioner "local-exec" {
    command = "kind create cluster --config cluster-generated.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name devops-coderhouse"
  }

  depends_on = [
    local_file.kind_config
  ]
}
