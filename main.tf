provider "aws" {
  region = "us-east-1"
  version = "~> 1.57.0"
}

# TODO - Read https://www.terraform.io/docs/backends/types/s3.html for information on how to organize and approaches to locking (dynamodb)
terrterraform {
  backend "s3" {
    bucket = "TODO - your bucket name"
    key    = "TODO - your account name.tfstate"
    region = "us-east-1"
  }
}

module "ops_users" {
  source = "modules/users"

  ops_users = [
    "TODO - your admin users"
  ]
  ro_ops_users = [
    "TODO - your readonly users"
  ]
}
