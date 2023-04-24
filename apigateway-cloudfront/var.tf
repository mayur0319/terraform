variable "rest_api_name"{
    type = string
    description = "Name of the API Gateway created"
    default = "terraform-api-gateway"
}

variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}

variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "dev"
}


