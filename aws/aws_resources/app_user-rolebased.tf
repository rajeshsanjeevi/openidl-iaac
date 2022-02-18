#IAM user for openidl application configuration
resource "aws_iam_user" "openidl_apps_user1" {
  name = "${local.std_name}-openidl-apps-user1"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-openidl-apps-user", Cluster_type = "both" })
}
resource "aws_iam_access_key" "openidl_apps_access_key1" {
  user = aws_iam_user.openidl_apps_user1.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM policy of the openidl app user that allows to assume a specific role
resource "aws_iam_user_policy" "openidl_apps_user_policy1" {
  name = "${local.std_name}-openidl-apps-user1"
  user = aws_iam_user.openidl_apps_user1.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.openidl_apps_iam_role.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "apps-user"
                }
            }
        }
    ]
  })
}
#IAM role - apps user can assume to access specific OpenIDL related AWS resources
resource "aws_iam_role" "openidl_apps_iam_role" {
  name = "${local.std_name}-openidl-apps"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.openidl_apps_user1.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "apps-user"
                }
            }
        }
    ]
  })
  managed_policy_arns = [var.org_name == "aais" ? aws_iam_policy.openidl_aais_apps_role_policy[0].arn : aws_iam_policy.openidl_nonaais_apps_role_policy[0].arn]
  tags = merge(local.tags, {Name = "${local.std_name}-openidl-apps", Cluster_type = "both"})
  description = "The iam role that is used with OpenIDL apps to access AWS resources"
  max_session_duration = 3600
}
#iam policy for openidl apps role
resource "aws_iam_policy" "openidl_aais_apps_role_policy" {
  count = var.org_name == "aais" ? 1 : 0
  name   = "${local.std_name}-OpenIDL-APPs-Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" : ""
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": "*"
        }
    ]
  })
  tags = merge(local.tags,
    { "Name" = "${local.std_name}-OpenIDL-APPs-Policy",
  "Cluster_type" = "both" })
}
resource "aws_iam_policy" "openidl_nonaais_apps_role_policy" {
  count = var.org_name == "aais" ? 0 : 1
  name   = "${local.std_name}-OpenIDL-APPs-Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "GetPutAllowHDS",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*",
            ]
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" : ""
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": "*"
        }
    ]
  })
  tags = merge(local.tags,
    { "Name" = "${local.std_name}-OpenIDL-APPs-Policy",
  "Cluster_type" = "both" })
}
