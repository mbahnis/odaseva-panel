# Ce fichier accueillera les appels aux modules au fur et à mesure de leur création.

module "kms" {
  source       = "./modules/kms"
  project_name = var.project_name
  environment  = var.environment
}
