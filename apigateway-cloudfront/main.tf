provider "aws" {
  region = var.region
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.rest_api_name
}
resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "movies"
}
resource "aws_api_gateway_method" "rest_api_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}
resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the movies API!"
    })
  }
} 

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_resource.id,
      aws_api_gateway_method.rest_api_get_method.id,
      aws_api_gateway_integration.rest_api_get_method_integration.id
    ]))
  }
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name
}

#Cloudfront Code

#creating OAI :
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Lambda assingments"
}

#creating AWS Cloudfront distribution :
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled = true
  #   aliases             = [var.domain_name]
#   default_root_object = "website/index.html"
#   origin {

#     domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
#     origin_id   = aws_s3_bucket.bucket.id
#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

    origin {
    # domain_name = "${aws_api_gateway_deployment.rest_api_deployment.invoke_url}.execute-api.${var.region}.amazonaws.com"
    domain_name = "${aws_api_gateway_deployment.rest_api_deployment.execution_arn}"
    origin_path = "/${var.rest_api_stage_name}"
    origin_id   = "Custome-${aws_api_gateway_deployment.rest_api_deployment.invoke_url}.execute-api.${var.region}.amazonaws.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "Custome-${aws_api_gateway_deployment.rest_api_deployment.invoke_url}.execute-api.${var.region}.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA"]
    }
  }
  tags = {
    "Project"   = "hands-on.cloud"
    "ManagedBy" = "Terraform"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_zone" "hosted_zone" {
  name = "demo.hands-on-cloud.com"
}