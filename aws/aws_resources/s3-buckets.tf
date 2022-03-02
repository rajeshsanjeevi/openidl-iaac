#creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_hds" {
  count = var.org_name == "aais" ? 1 : 1 #update to 0 : 1
  bucket = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
    },)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
      }
    }
  }
  #logging {
  #  target_bucket = var.enable_s3_access_logging ? aws_s3_bucket.s3_bucket_access_logs[0].id : ""
  #  target_prefix = var.enable_s3_access_logging ? "log-hds/" : ""
  #}
}
#blocking public access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_hds" {
  count = var.org_name == "aais" ? 1 : 1
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_hds[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_hds, aws_s3_bucket_policy.s3_bucket_policy_hds]
}
#setting up a bucket policy to restrict access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_policy" "s3_bucket_policy_hds" {
  count = var.org_name == "aais" ? 1 : 1
  bucket     = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  depends_on = [aws_s3_bucket.s3_bucket_hds]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${aws_iam_role.openidl_apps_iam_role.arn}", "${aws_iam_user.openidl_apps_user.arn}"]
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
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ]
        },
        {
            "Sid": "AllowAccessIAMRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ]
        },
        {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}" ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
        },
        {
			"Sid": "DenyOthers",
			"Effect": "Deny",
			"Principal": "*",
            "Action": "*",
			"Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ],
			"Condition": {
				"StringNotLike": {
					"aws:userid": [
                        "${aws_iam_role.openidl_apps_iam_role.unique_id}:*",
                        "${aws_iam_user.openidl_apps_user.unique_id}",
                        "${data.aws_iam_role.terraform_role.unique_id}:*",
						"${var.aws_account_number}",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${aws_iam_role.openidl_apps_iam_role.name}/openidl"

					]
				}
			}
		}
    ]
})
}
#creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_logos_public" {
  count = var.create_s3_bucket_public ? 1 : 0
  bucket = "${local.std_name}-${var.s3_bucket_name_logos}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_logos}"
    },)
}
#blocking public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_logos_public_access_block" {
  count = var.create_s3_bucket_public ? 1 : 0
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  bucket                  = aws_s3_bucket.s3_bucket_logos_public[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_logos_public, aws_s3_bucket_policy.s3_bucket_logos_policy]
}
#S3 bucket policy for public s3 bucket
resource "aws_s3_bucket_policy" "s3_bucket_logos_policy" {
  count = var.create_s3_bucket_public ? 1 : 0
  bucket     = "${local.std_name}-${var.s3_bucket_name_logos}"
  depends_on = [aws_s3_bucket.s3_bucket_logos_public]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [ "s3:GetObject", "s3:GetObjectVersion"],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",

            ]
        },
      {
            "Sid": "AllowIAMAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}"]
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
            ]
        },
      {
        "Sid":  "HTTPRestrict",
        "Effect": "Deny",
        "Principal":  "*",
        "Action": "s3:*",
        "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}" ]
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        "Sid": "DenyOthers",
        "Effect": "Deny",
        "Principal": "*",
        "NotAction": [ "s3:GetObject", "s3:GetObjectVersion"],
        "Resource": [
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
        ],
        "Condition": {
		  "StringNotLike": {
		      "aws:userid": [
                  "${aws_iam_role.openidl_apps_iam_role.unique_id}:*",
                  "${aws_iam_user.openidl_apps_user.unique_id}",
                  "${data.aws_iam_role.terraform_role.unique_id}:*",
				  "${var.aws_account_number}",
                  "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
                  "arn:aws:sts:::${var.aws_account_number}:assumed-role/${aws_iam_role.openidl_apps_iam_role.name}/openidl"
              ]
          }
		}
      }
    ]
  })
}
#S3 bucket for storing access logs of s3 and its objects
resource "aws_s3_bucket" "s3_bucket_access_logs" {
  count = var.enable_s3_access_logging ? 1 : 0
  bucket = "${local.std_name}-${var.s3_bucket_name_access_logs}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_access_logs}"
    },)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
      }
    }
  }
}
#blocking public access to s3 bucket used for s3 access logging
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_access_logs" {
  count = var.enable_s3_access_logging ? 1 : 0
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_access_logs[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_access_logs, aws_s3_bucket_policy.s3_bucket_policy_access_logs]
}
#setting up a bucket policy to restrict access to s3 bucket used for s3 access logging
resource "aws_s3_bucket_policy" "s3_bucket_policy_access_logs" {
  count = var.enable_s3_access_logging ? 1 : 0
  bucket     = "${local.std_name}-${var.s3_bucket_name_access_logs}"
  depends_on = [aws_s3_bucket.s3_bucket_access_logs]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessIAMRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*"
            ]
        },
        {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}"],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
        },
        {
			"Sid": "DenyOthers",
			"Effect": "Deny",
			"Principal": "*",
            "Action": "*",
			"Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*"
            ],
			"Condition": {
				"StringNotLike": {
					"aws:userid": [
                        "${data.aws_iam_role.terraform_role.unique_id}:*",
						"${var.aws_account_number}",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
					]
				}
			}
		}
    ]
  })
}