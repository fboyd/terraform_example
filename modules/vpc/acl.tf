# Bring the default ACL into management with the no traffic in or out
resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.vpc.default_network_acl_id}"

  tags = {
    Name = "${var.name}_default",
    Owner = "terraform"
  }
}

# Public ACL
resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  tags = {
    Name = "${var.name}_public",
    Owner = "terraform"
  }
}

####################
# Public Egress
####################
# TODO maybe we should only do things like ephemeral and leave the other rules to be customized by VPC
resource "aws_network_acl_rule" "public_http_out" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number = 100
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_network_acl_rule" "public_https_out" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number = 110
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "public_ephemeral_out" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number = 1000
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

####################
# Public Ingress
####################
resource "aws_network_acl_rule" "public_https_in" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number = 120
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "public_ephemeral_in" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number = 1000
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

# Private ACL
resource "aws_network_acl" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags = {
    Name = "${var.name}_private",
    Owner = "terraform"
  }
}

####################
# Private Egress
####################
resource "aws_network_acl_rule" "private_http_out" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number = 100
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_network_acl_rule" "private_https_out" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number = 110
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "private_ephemeral_out" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number = 1000
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

####################
# Private Ingress
####################
resource "aws_network_acl_rule" "private_https_in" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number = 120
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "${aws_vpc.vpc.cidr_block}"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "private_ephemeral_in" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number = 1000
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}
