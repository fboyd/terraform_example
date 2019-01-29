#################
# Groups
#################
resource "aws_iam_group" "ops" {
  name = "devops"
}

resource "aws_iam_group" "ro_ops" {
  name = "readonlydevops"
}

#################
# Users
#################
resource "aws_iam_user" "ops" {
  count = "${length(var.ops_users)}"
  name = "${element(var.ops_users, count.index)}"
}

resource "aws_iam_user" "ro_ops" {
  count = "${length(var.ro_ops_users)}"
  name = "${element(var.ro_ops_users, count.index)}"
}

#################
# Group association
#################
resource "aws_iam_group_membership" "ops_users" {
  name = "ops-membership"

  group = "${aws_iam_group.ops.name}"
  users = ["${var.ops_users}"]
}

resource "aws_iam_group_membership" "ro_ops_users" {
  name = "ro_ops-membership"

  group = "${aws_iam_group.ro_ops.name}"
  users = ["${var.ro_ops_users}"]
}

#################
# Policy attachments
#################
resource "aws_iam_group_policy_attachment" "ops-admin" {
  group = "${aws_iam_group.ops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "ops-readonly" {
  group = "${aws_iam_group.ro_ops.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
