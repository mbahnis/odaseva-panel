# Ce fichier accueillera les appels aux modules au fur et à mesure de leur création.

module "kms" {
  source       = "./modules/kms"
  project_name = var.project_name
  environment  = var.environment
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  table_name  = "${var.project_name}-candidates"
  kms_key_arn = module.kms.key_arn
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-cv"
  kms_key_arn = module.kms.key_arn
}

module "iam" {
  source             = "./modules/iam"
  project_name       = var.project_name
  dynamodb_table_arn = module.dynamodb.table_arn
  dynamodb_gsi_name  = module.dynamodb.gsi_name
  s3_bucket_arn      = module.s3.bucket_arn
  kms_key_arn        = module.kms.key_arn
}
