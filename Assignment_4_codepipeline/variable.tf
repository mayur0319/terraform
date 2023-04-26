variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}

variable "dockerhub_credentials" {
  type        = string
}

variable "codestar_connector_credentials" {
  type = string
}

