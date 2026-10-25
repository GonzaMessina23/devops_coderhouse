variable "cluster_name" {
  description = "Nombre del cluster Kubernetes Kind"
  type        = string
  default     = "devops-coderhouse"
}

variable "http_port" {
  description = "Puerto HTTP disponible en Windows"
  type        = number
  default     = 8085
}
