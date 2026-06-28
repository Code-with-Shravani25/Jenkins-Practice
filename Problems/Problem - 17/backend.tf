terraform {
  backend "s3" {
    bucket         = "terraform-locking-state-file-practice"
    key            = "ec2-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
