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

locals (
  "environment" = "infrastructure"
  "vpc_cidr" = "10.1.2.0/24"
  "private_subnets" = ["10.1.2.0/27","10.1.2.32/27"]
  "public_subnets" = ["10.1.2.128/27","10.1.2.160/27"]
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

# Create VPC
module "vpc" {
  source = "modules/vpc"
  name = "infrastructure"
  cidr = "${local.vpc_cidr}"
  availability_zones = ["us-east-1a","us-east-1b"]
  private_subnet_cidr = ["${local.private_subnets}"]
  public_subnet_cidr = ["${local.public_subnets}"]
}

# Allow HTTPS in from anywhere for Network ACL
resource "aws_network_acl_rule" "private_https_in" {
  network_acl_id = "${module.vpc.private_subnet_acl}"
  rule_number = 121
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

