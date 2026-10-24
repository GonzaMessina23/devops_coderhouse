
moved {
  from = module.kubernetes
  to   = module.kubernetes_test
}

module "kubernetes_test" {
  source = "./modules/kubernetes"

  namespace_name = "devops-terraform-test"
}

module "kubernetes_app" {
  source = "./modules/kubernetes"

  namespace_name = "devops-app"
}

module "app" {
  source = "./modules/app"

  namespace = module.kubernetes_app.namespace_name
}
