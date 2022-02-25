#IAM user and relevant credentials required for BAF automation
resource "aws_iam_user" "baf_user1" {
  name = "${local.std_name}-baf-user"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-baf-user", cluster_type = "blockchain" })
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
  name = "${local.std_name}-baf-user-policy"
  user = aws_iam_user.baf_user1.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.baf_user_role.name}",
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
  name = "${local.std_name}-baf-automation1"
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
  managed_policy_arns = [aws_iam_policy.baf_user_role_policy.arn]
  tags = merge(local.tags, {name = "${local.std_name}-baf-automation1", cluster_type = "blockchain"})
  description = "The iam role that is used for baf automation"
  max_session_duration = 3600
}
resource "aws_iam_policy" "baf_user_role_policy" {
  name   = "${local.std_name}-BAFPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEKS",
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": [
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.app_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.blk_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.app_cluster_name}/*",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.blk_cluster_name}/*",
              ]
        },
        {
            "Sid": "AllowPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        },
        {
            "Sid": "AllowEKSRead",
            "Effect": "Allow",
            "Action": [
                "iam:ListPolicies",
                "iam:GetPolicyVersion",
                "eks:ListNodegroups",
                "eks:DescribeFargateProfile",
                "iam:GetPolicy",
                "eks:ListTagsForResource",
                "iam:ListGroupPolicies",
                "eks:ListAddons",
                "eks:DescribeAddon",
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "iam:ListPolicyVersions",
                "eks:DescribeIdentityProviderConfig",
                "eks:ListUpdates",
                "eks:DescribeUpdate",
                "eks:AccessKubernetesApi",
                "iam:ListUsers",
                "iam:ListAttachedGroupPolicies",
                "eks:DescribeCluster",
                "iam:GetGroupPolicy",
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:ListIdentityProviderConfigs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ViewOwnUserInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:GetUser"
            ],
            "Resource": [
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "NavigateInConsole",
            "Effect": "Allow",
            "Action": [
                "iam:GetGroupPolicy",
                "iam:GetPolicyVersion",
                "iam:GetPolicy",
                "iam:ListAttachedGroupPolicies",
                "iam:ListGroupPolicies",
                "iam:ListPolicyVersions",
                "iam:ListPolicies",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ListRoles",
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:*:${var.aws_account_number}:parameter/*"
            ]
        }

    ]
})
  tags = merge(local.tags,
    { "name" = "${local.std_name}-BAFPolicy",
      "cluster_type" = "blockchain" })
}
#IAM user and relevant credentials to use with github actions for EKS resource provisioning
resource "aws_iam_user" "git_actions_user" {
  name = "${local.std_name}-gitactions-admin"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-gitactions-admin", cluster_type = "both" })
}
resource "aws_iam_access_key" "git_actions_access_key" {
  user = aws_iam_user.git_actions_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM policy to assume git actions role for git actions user
resource "aws_iam_user_policy" "git_actions_policy" {
  name = "${local.std_name}-gitactions-admin-policy"
  user = aws_iam_user.git_actions_user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.git_actions_admin_role.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "git-actions"
                }
            }
        }
    ]
  })
}
#iam policy for git actions role
resource "aws_iam_policy" "git_actions_admin_policy" {
  name   = "${local.std_name}-GITACTIONSAdminPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEKS",
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": [
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.app_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.blk_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.app_cluster_name}/*",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.blk_cluster_name}/*",
              ]
        },
        {
            "Sid": "AllowPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        },
        {
            "Sid": "AllowEKSRead",
            "Effect": "Allow",
            "Action":[
                "iam:ListPolicies",
                "iam:GetPolicyVersion",
                "eks:ListNodegroups",
                "eks:DescribeFargateProfile",
                "iam:GetPolicy",
                "eks:ListTagsForResource",
                "iam:ListGroupPolicies",
                "eks:ListAddons",
                "eks:DescribeAddon",
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "iam:ListPolicyVersions",
                "eks:DescribeIdentityProviderConfig",
                "eks:ListUpdates",
                "eks:DescribeUpdate",
                "eks:AccessKubernetesApi",
                "iam:ListUsers",
                "iam:ListAttachedGroupPolicies",
                "eks:DescribeCluster",
                "iam:GetGroupPolicy",
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:ListIdentityProviderConfigs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ViewOwnUserInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:GetUser"
            ],
            "Resource": [
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "NavigateInConsole",
            "Effect": "Allow",
            "Action": [
                "iam:GetGroupPolicy",
                "iam:GetPolicyVersion",
                "iam:GetPolicy",
                "iam:ListAttachedGroupPolicies",
                "iam:ListGroupPolicies",
                "iam:ListPolicyVersions",
                "iam:ListPolicies",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ListRoles",
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:*:${var.aws_account_number}:parameter/*"
            ]
        },
        {
            "Action": [
                "secretsmanager:*"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-vault-unseal-key-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-config-vault-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-kvs-vault-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-ca-app-user-token-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-mongodb-user-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-mongodb-user-token-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-mongodb-root-token-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.aws_env}-orderer-tls-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.aws_env}-analytics-msp-??????",
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.aws_env}-*-msp-??????"
            ]
        },
        {
            "Sid": "AllowKMSAccess",
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:Decrypt",
                "kms:Encrypt"
            ],
            "Resource": "*"
        }
    ]
})
  tags = merge(local.tags,
    { "name" = "${local.std_name}-GITACTIONSAdminPolicy",
      "cluster_type" = "both" })
}
#iam role - to perform git actions on EKS resources
resource "aws_iam_role" "git_actions_admin_role" {
  name = "${local.std_name}-gitactions-admin"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.git_actions_user.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "git-actions"
                }
            }
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.git_actions_admin_policy.arn]
  tags = merge(local.tags, {name = "${local.std_name}-gitactions-admin", cluster_type = "both"})
  description = "The iam role that is used to manage EKS cluster resources using git actions"
  max_session_duration = 7200
}

