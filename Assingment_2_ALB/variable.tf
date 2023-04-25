variable "aws_region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-east-1"
}
variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket"
  default     = "tf-s3-website-"
}

variable "instance_type" {
  type        = string
  description = "Instance_type"
  default     = "t2.micro"
}

variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "demo.hands-on-cloud.com"
}