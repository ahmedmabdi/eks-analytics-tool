terraform {
  backend "s3" {
    bucket = "ny-terraform-states"
    key = "project-eks/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}