output "cloudwatch_logs" {
  value     = aws_cloudwatch_log_group.api_gateway_logs.arn
}