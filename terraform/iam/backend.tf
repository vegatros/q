terraform {
  backend "s3" {
    bucket         = "terraform-state-925185632967"
    key            = "iam/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
