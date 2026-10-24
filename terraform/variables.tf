variable "kubeconfig_path" {
  description = "Ruta del archivo de configuración de Kubernetes"
  type        = string
  default     = "~/.kube/config"
}

variable "kubernetes_context" {
  description = "Contexto de Kubernetes utilizado por Terraform"
  type        = string
  default     = "docker-desktop"
}
