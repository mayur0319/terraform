resource "aws_s3_bucket" "cicd_artifacts" {
  bucket = "artifacts-bucket-cicd"
}

# resource "aws_s3_bucket_acl" ""bucket_acl {
#   bucket = aws_s3_bucket.cicd_artifacts.id
#   acl = "private"
# }