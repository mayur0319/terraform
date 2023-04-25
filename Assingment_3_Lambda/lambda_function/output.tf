output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}
output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "aws_s3_bucket_domain" {
  value = aws_s3_bucket.lambda_bucket.bucket_domain_name
}

output "aws_s3_bucket_id" {
  value = aws_s3_bucket.lambda_bucket.id
}