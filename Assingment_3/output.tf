output "rest_api_url" {
  value = module.api_gateway.rest_api_url
}

output "cdn_domain_name" {
  value = module.Cloudfront.cloudfront_domain_name
}