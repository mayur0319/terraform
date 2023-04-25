output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cf_dist.domain_name
}