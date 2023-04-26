terraform{
    backend "s3" {
        bucket = "mayur-cicd-bucket"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}