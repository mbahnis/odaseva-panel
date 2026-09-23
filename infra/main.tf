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

module "lambda_create_candidate" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-create-candidate"
  source_dir    = "${path.module}/../src/create_candidate"
  role_arn      = module.iam.create_candidate_role_arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
    S3_BUCKET_NAME      = module.s3.bucket_name
  }
}

module "lambda_get_candidate" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-get-candidate"
  source_dir    = "${path.module}/../src/get_candidate"
  role_arn      = module.iam.get_candidate_role_arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
    S3_BUCKET_NAME      = module.s3.bucket_name
  }
}

module "lambda_list_candidates" {
  source        = "./modules/lambda"
  function_name = "${var.project_name}-list-candidates"
  source_dir    = "${path.module}/../src/list_candidates"
  role_arn      = module.iam.list_candidates_role_arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
    GSI_NAME            = module.dynamodb.gsi_name
  }
}

module "cognito" {
  source       = "./modules/cognito"
  project_name = var.project_name
  environment  = var.environment
}

module "api_gateway" {
  source       = "./modules/api_gateway"
  project_name = var.project_name
  aws_region   = var.aws_region

  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_app_client_id = module.cognito.app_client_id

  create_candidate_invoke_arn    = module.lambda_create_candidate.lambda_invoke_arn
  create_candidate_function_name = module.lambda_create_candidate.lambda_function_name
  get_candidate_invoke_arn       = module.lambda_get_candidate.lambda_invoke_arn
  get_candidate_function_name    = module.lambda_get_candidate.lambda_function_name
  list_candidates_invoke_arn     = module.lambda_list_candidates.lambda_invoke_arn
  list_candidates_function_name  = module.lambda_list_candidates.lambda_function_name
}
