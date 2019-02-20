resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags      {
    Name = "${var.name}",
    Owner = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create an Internet Gateway for public subnets
resource "aws_internet_gateway" "ig_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.name}_igw",
    Owner = "terraform"
  }
}

# Public route (no NAT)
resource "aws_route_table" "internet_access" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}_internet_access",
    Owner = "terraform"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.internet_access.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ig_gw.id}"
}

# Subnets
# One public and one private in each AZs
resource "aws_subnet" "public" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  cidr_block = "${element(var.public_subnet_cidr, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}_public_${element(var.availability_zones, count.index)}",
    Owner = "terraform"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.availability_zones)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.internet_access.id}"
}

resource "aws_subnet" "private" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  cidr_block = "${element(var.private_subnet_cidr, count.index)}"

  tags {
    Name = "${var.name}_private_${element(var.availability_zones, count.index)}",
    Owner = "terraform"
  }
}

# elastic IPs for NAT gateways
resource "aws_eip" "nat_gw_eip" {
  count = "${length(var.availability_zones)}"
  vpc = true

  # IPs are registered with external API providers and should not be destroyed
  lifecycle {
    prevent_destroy = true
  }
}

# Create a NAT Gateway for each AZ
resource "aws_nat_gateway" "nat_gw" {
  count = "${length(var.availability_zones)}"
  allocation_id = "${element(aws_eip.nat_gw_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

# Private routes (no NAT)
resource "aws_route_table" "nat_access" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}_nat_access_${element(var.availability_zones, count.index)}",
    Owner = "terraform"
  }
}

resource "aws_route" "private_internet_nat" {
  count = "${length(var.availability_zones)}"
  route_table_id = "${element(aws_route_table.nat_access.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}

resource "aws_route_table_association" "nat_access" {
  count = "${length(var.availability_zones)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat_access.*.id, count.index)}"
}
