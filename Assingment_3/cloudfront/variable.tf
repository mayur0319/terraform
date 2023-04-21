variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "demo.hands-on-cloud.com"
}
variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}

variable "aws_rest_api_id" {
  type        = string
  description = "the rest api id"
}

variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "dev"
}

variable "bucket_domain_id" {
type = string  
}

variable "bucket_domain_name" {
  type = string
}

