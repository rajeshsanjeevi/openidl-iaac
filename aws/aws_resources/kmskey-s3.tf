#creating kms key that is used to encrypt data at rest in S3 bucket used for HDS data extract for analytics node
resource "aws_kms_key" "s3_kms_key" {
  count = var.org_name == "aais" && var.create_kms_keys != "false" ? 0 : 1
  description             = "The kms key for ${var.org_name}-${var.aws_env}-s3-key"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  tags = merge(
    local.tags,
    {
      "name" = "s3-kms-key"
    },)
  policy = jsonencode({
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowaccessforKeyAdministrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": [
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
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allowuseofthekey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allowattachmentofpersistentresources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
})
}
#setting up an alias for the kms key used with s3 bucket data encryption which is used for HDS data extract for analytics node
resource "aws_kms_alias" "s3_kms_key_alais" {
  count = var.org_name == "aais" && var.create_kms_keys != "false" ? 0 : 1
  name          = "alias/${local.std_name}-s3-key"
  target_key_id = aws_kms_key.s3_kms_key[0].id
}