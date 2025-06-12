provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket = "rsschool-devops-terraform-state-kirylkatselnikau" # заменишь позже на свой
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
