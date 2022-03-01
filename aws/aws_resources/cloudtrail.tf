#kms key for application cluster and blockchain cluster encryption
resource "aws_kms_key" "ct_cw_logs_kms_key" {
  count = var.create_cloudtrial && var.create_kms_keys ? 1 : 0
  description             = "The KMS key used for cloudwatch log group receives events from cloudtrial"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = data.aws_iam_policy_document.cloudtrail_kms_policy_doc.json
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-ct-cw-logs-key"
      "cluster_type" = "both"
    },)
}
#kms key alias for cloudwatch logs related to cloudtrail
resource "aws_kms_alias" "ct_cw_logs_kms_key_alias" {
  count = var.create_cloudtrial && var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-ct-cw-logs-key"
  target_key_id = aws_kms_key.ct_cw_logs_kms_key[0].id
}
#setting up cloudwatch logs
resource "aws_cloudwatch_log_group" "ct_cw_logs" {
  count = var.create_cloudtrial ? 1 : 0
  name = "${local.std_name}-cloudtrail-logs"
  retention_in_days = var.cw_logs_retention_period
  kms_key_id = var.create_kms_keys ? aws_kms_key.ct_cw_logs_kms_key[0].arn : var.cloudtrail_cwlogs_kms_key_arn
  tags = merge(local.tags, { name = "${local.std_name}-ct-cw-logs-group", cluster_type = "both"})
  depends_on = [aws_kms_key.ct_cw_logs_kms_key]
}
#setting up iam role for cloudwatch related to cloudtrail
resource "aws_iam_role" "ct_cw_role" {
  count = var.create_cloudtrial ? 1 : 0
  name = "${local.std_name}-ct-cw"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}
#enabling cloudtrail
resource "aws_cloudtrail" "ct_events" {
    count = var.create_cloudtrial ? 1 : 0
    name = "${local.std_name}-cloudtrail"
    s3_bucket_name = aws_s3_bucket.ct_cw_s3_bucket[0].bucket
    cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.ct_cw_logs[0].arn}:*"
    cloud_watch_logs_role_arn = aws_iam_role.ct_cw_role[0].arn
    enable_log_file_validation = true
    enable_logging = true
    include_global_service_events = true
    is_multi_region_trail = false
    is_organization_trail = false
    kms_key_id = var.create_kms_keys ? aws_kms_key.ct_cw_logs_kms_key[0].arn : var.cloudtrail_cwlogs_kms_key_arn
     event_selector {
            include_management_events = true
            read_write_type = "WriteOnly"
    }
    tags = merge(local.tags, {name = "${local.std_name}-cloudtrail", cluster_type = "both"})
    depends_on = [aws_cloudwatch_log_group.ct_cw_logs, aws_s3_bucket_policy.ct_cw_s3_bucket_policy]
}
#iam policy for cloudwatch logs related to cloudtrail
resource "aws_iam_policy" "ct_cw_logs" {
  count = var.create_cloudtrial ? 1 : 0
  name   = "${local.std_name}-CTCWLogsPolicy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}
#iam policy attachment for cloudwatch logs related to cloudtrail
resource "aws_iam_policy_attachment" "ct_cw_policy_attachment" {
  count = var.create_cloudtrial ? 1 : 0
  name       = "${local.std_name}-ct-cw-policy"
  policy_arn = aws_iam_policy.ct_cw_logs[0].arn
  roles      = [aws_iam_role.ct_cw_role[0].name]
}
#creating an s3 bucket
resource "aws_s3_bucket" "ct_cw_s3_bucket" {
  count = var.create_cloudtrial ? 1 : 0
  bucket = "${local.std_name}-${var.s3_bucket_name_cloudtrail}"
  acl    = "private"
  #policy = aws_s3_bucket_policy.bucket_policy.id
  force_destroy = true
  versioning {
    enabled = false
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_cloudtrail}"
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
#blocking public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "ct_cw_s3_bucket_public_access_block" {
  count = var.create_cloudtrial ? 1 : 0
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.ct_cw_s3_bucket[0].id
  depends_on              = [aws_s3_bucket.ct_cw_s3_bucket, aws_s3_bucket_policy.ct_cw_s3_bucket_policy]
}
#setting up a bucket policy to restrict access
resource "aws_s3_bucket_policy" "ct_cw_s3_bucket_policy" {
  count = var.create_cloudtrial ? 1 : 0
  bucket     = "${local.std_name}-${var.s3_bucket_name_cloudtrail}"
  depends_on = [aws_s3_bucket.ct_cw_s3_bucket]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_cloudtrail}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_cloudtrail}/AWSLogs/${var.aws_account_number}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
      {
            "Sid": "AllowAccessIAMRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_cloudtrail}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_cloudtrail}/*",
            ]
        },
      {
        Sid       = "HTTPRestrict"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_cloudtrail}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
})
}
