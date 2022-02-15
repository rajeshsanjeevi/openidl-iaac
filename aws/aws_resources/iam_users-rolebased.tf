#IAM user and relevant credentials required for BAF automation
resource "aws_iam_user" "baf_user1" {
  name = "${local.std_name}-baf-automation1"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-baf-automation1", Cluster_type = "both" })
}
resource "aws_iam_access_key" "baf_user_access_key1" {
  user = aws_iam_user.baf_user1.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM policy of the openidl app user that allows to assume a specific role
resource "aws_iam_user_policy" "baf_user_policy1" {
  name = "${local.std_name}-openidl-apps-user1"
  user = aws_iam_user.baf_user1.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.<fixthis>.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "baf-user"
                }
            }
        }
    ]
  })
}
#IAM role for blockchain automation framework
resource "aws_iam_role" "baf_user_role" {
  name = "${local.std_name}-baf-automation"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.baf_user1.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "baf-user"
                }
            }
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.baf_role_policy.arn]
  tags = merge(local.tags, {Name = "${local.std_name}-baf-automation", Cluster_type = "both"})
  description = "The iam role that is used for baf automation"
  max_session_duration = 3600
}
resource "aws_iam_policy" "baf_role_policy" {
  name   = "${local.std_name}-BAFPolicy"
  policy = file("resources/policies/eks-admin-policy.json")
  tags = merge(local.tags,
    { "Name" = "${local.std_name}-BAFPolicy",
  "Cluster_type" = "both" })
}

