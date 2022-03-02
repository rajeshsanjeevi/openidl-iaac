#kms key for hcp vault cluster unseal
resource "aws_kms_key" "vault_kms_key" {
  count = var.create_kms_keys ? 1 : 0
  description             = "The KMS key used for vault cluster"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-vault-kms-key",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowaccessforKeyAdministrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}"]
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
        ],
        "Resource" : "*"
      },
      {
            "Sid": "Allowuseofthekey",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}", aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
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
        "Sid" : "Allowattachmentofpersistentresources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}", aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
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
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-vault-kms-key"
      "cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "vault_kms_key_alias" {
  count = var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-vault-kms-key"
  target_key_id = aws_kms_key.vault_kms_key[0].id
}
