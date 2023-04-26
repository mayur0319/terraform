variable "aws_region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}
variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket"
  default     = "s3-website-hosting"
}

variable "instance_type" {
  type        = string
  description = "Instance_type"
  default     = "t2.micro"
}

variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "hands-on.com"
}
