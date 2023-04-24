module "lambda_function" {
  source = "./lambda_function"
}

module "api_gateway" {
  source                 = "./apigtw"
  api_gateway_region     = var.region
  api_gateway_account_id = var.account_id
  lambda_function_name   = module.lambda_function.lambda_function_name
  lambda_function_arn    = module.lambda_function.lambda_function_arn
  # apigtw_logs            = module.Cloudwatch.cloudwatch_logs
  depends_on = [
    module.lambda_function
  ]
}

module "Cloudfront" {
  source          = "./cloudfront"
  aws_rest_api_id = module.api_gateway.rest_api_id
  bucket_domain_id  = module.lambda_function.aws_s3_bucket_id
  bucket_domain_name = module.lambda_function.aws_s3_bucket_domain
}

module "Cloudwatch" {
  source = "./cloudwatch"
}


