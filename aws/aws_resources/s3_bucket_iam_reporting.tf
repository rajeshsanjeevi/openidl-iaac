#creating an s3 bucket for reporting
resource "aws_s3_bucket" "s3_bucket_reporting" {
  count = var.org_name == "aais" ? 0 : 1
  bucket = "${local.std_name}-${var.s3_bucket_name_reporting}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "Name" = "${local.std_name}-${var.s3_bucket_name_reporting}"
    },)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_kms_key_reporting.id
      }
    }
  }
}
#blocking public access to s3 bucket used for reporting
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_reporting" {
  count = var.org_name == "aais" ? 0 : 1
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_reporting.id
  depends_on              = [aws_s3_bucket.s3_bucket_reporting, aws_s3_bucket_policy.s3_bucket_policy_reporting]
}
#setting up a bucket policy to restrict access to s3 bucket used for reporting
resource "aws_s3_bucket_policy" "s3_bucket_policy_reporting" {
  count = var.org_name == "aais" ? 0 : 1
  bucket     = "${local.std_name}-${var.s3_bucket_name_reporting}"
  depends_on = [aws_s3_bucket.s3_bucket_reporting]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.reporting_user.arn}"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*"
            ]
        },
      {
        Sid       = "HTTPRestrict"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
})
}
#creating kms key that is used to encrypt data at rest in S3 bucket used for reporting
resource "aws_kms_key" "s3_kms_key_reporting" {
  count = var.org_name == "aais" ? 0 : 1
  description             = "The kms key for s3 bucket reporting"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  tags = merge(
    local.tags,
    {
      "Name" = "s3-bucket-reporting-kms-key"
    },)
  policy = jsonencode({
    "Id" : "${local.std_name}-${var.s3_bucket_name_reporting}",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EnableIAMUserPermissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_number}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowaccessforKeyAdministrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.aws_role_arn}"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      	{
        "Sid" : "EnableAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.reporting_user.arn}"
        },
        "Action" : [
			"kms:Encrypt",
			"kms:Decrypt",
			"kms:DescribeKey"
		],
        "Resource" : "*"
    },
      {
        "Sid" : "Allowattachmentofpersistentresources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.aws_role_arn}"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}
#setting up an alias for the kms key used with s3 bucket data encryption which is used for reporting
resource "aws_kms_alias" "kms_alias_reporting" {
  count = var.org_name == "aais" ? 0 : 1
  name          = "alias/${local.std_name}-${var.s3_bucket_name_reporting}"
  target_key_id = aws_kms_key.s3_kms_key_reporting.id
}
#IAM user and relevant credentials used for S3 bucket access which is used for reporting
resource "aws_iam_user" "reporting_user" {
  count = var.org_name == "aais" ? 0 : 1
  name = "${local.std_name}-reporting-user"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-reporting-user", Cluster_type = "both" })
}
resource "aws_iam_access_key" "reporting_user_access_key" {
  count = var.org_name == "aais" ? 0 : 1
  user = aws_iam_user.reporting_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
resource "aws_iam_user_policy" "reporting_user_policy" {
  count = var.org_name == "aais" ? 0 : 1
  name = "${local.std_name}-reporting-user-policy"
  user = aws_iam_user.reporting_user
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
            "Sid": "GetPutAllow",
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
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*",
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
            "Resource": [
                "${aws_kms_key.s3_kms_key_reporting.arn}"
            ]
        }
    ]
  })
}

