#creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_logos_public" {
  bucket = "${local.std_name}-${var.s3_bucket_name_logos}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "Name" = "${local.std_name}-${var.s3_bucket_name_logos}"
    },)
}
#blocking public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_logos_public_access_block" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
  bucket                  = aws_s3_bucket.s3_bucket_logos_public.id
  depends_on              = [aws_s3_bucket.s3_bucket_logos_public, aws_s3_bucket_policy.s3_bucket_policy_logos]
}
#S3 bucket policy for public s3 bucket
resource "aws_s3_bucket_policy" "s3_bucket_policy_logos" {
  bucket     = "${local.std_name}-${var.s3_bucket_name_logos}"
  depends_on = [aws_s3_bucket.s3_bucket_logos_public]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",

            ]
        },
      {
            "Sid": "AllowIAMAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}","arn:aws:iam::572551282206:user/rajesh.sanjeevi@itpeoplecorp.com"]
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
            ]
        },
      {
        Sid       = "HTTPRestrict"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}