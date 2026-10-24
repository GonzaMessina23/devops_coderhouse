output "namespace_name" {
  description = "Nombre del namespace creado"
  value       = kubernetes_namespace_v1.this.metadata[0].name
}
