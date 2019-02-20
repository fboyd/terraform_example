variable "name" { description = "Name of the VPC" }

variable "cidr" {
  description = "CIDR for the VPC"
}

variable "availability_zones" {
  type = "list"
  description = "List consisting of availability zones. Ex: us-east-1a,us-east-1c,us-east-1d,us-east-1e"
}

variable "public_subnet_cidr" {
  type = "list"
  description = "List of CIDR ranges for public subnets. Ex: 10.0.0.0/25,10.0.0.128/25,10.0.1.0/25,10.0.1.128/25"
}

variable "private_subnet_cidr" {
  type = "list"
  description = "List of CIDR ranges for private subnets. Ex: 10.0.2.0/24,10.0.3.0/24,10.0.4.0/24,10.0.5.0/24"
}

variable "github_cidr" {
  type = "list"
  description = "CIDR block for public Github services"
  default = [
    "192.30.252.0/22",
    "185.199.108.0/22"
  ]
}
