#-----------------------------------------------------------------------------------------------------------------
#aws cognito application client outputs
output "cognito_user_pool_id" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool.user_pool[0].id : null
  sensitive = true
}
output "cognito_app_client_id" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool_client.cognito_app_client[0].id : null
  sensitive = true
}
output "cognito_app_client_secret" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool_client.cognito_app_client[0].client_secret : null
  sensitive = true
}
#-----------------------------------------------------------------------------------------------------------------
#git actions user and baf automation user outputs
output "git_actions_iam_user_arn" {
  value = aws_iam_user.git_actions_user.arn
}
output "baf_automation_user_arn" {
  value = aws_iam_user.baf_user.arn
}
output "openidl_app_iam_user_arn"{
  value = aws_iam_user.openidl_apps_user.arn
}
output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin_role.arn
}
output "git_actions_admin_role_arn" {
  value = aws_iam_role.git_actions_admin_role.arn
}
#-----------------------------------------------------------------------------------------------------------------
#application cluster (EKS) outputs
output "app_cluster_endpoint" {
  value = module.app_eks_cluster.cluster_endpoint
}
output "app_cluster_name" {
  value = module.app_eks_cluster.cluster_id
}
output "app_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["app-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#blockchain cluster (EKS) outputs
output "blk_cluster_endpoint" {
  value = module.blk_eks_cluster.cluster_endpoint
}
output "blk_cluster_name" {
  value = module.blk_eks_cluster.cluster_id
}
output "blk_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#cloudtrail related
output "cloudtrail_s3_bucket_name" {
  value = var.create_cloudtrial ? aws_s3_bucket.s3_bucket[0].bucket : null
}
output "hds_data_s3_bucket_name" {
  value = var.org_name == "aais" ? null : aws_s3_bucket.s3_bucket_hds[0].bucket
}
output "s3_public_bucket_logos_name" {
  value = var.create_s3_bucket_public ? aws_s3_bucket.s3_bucket_logos_public[0].bucket : null
}
#-----------------------------------------------------------------------------------------------------------------
#Route53 entries
output "aws_name_servers" {
  value       = var.domain_info.r53_public_hosted_zone_required == "yes"  ? aws_route53_zone.zones[0].name_servers : null
  description = "The name servers to be updated in the domain registrar"
}
output "public_blk_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? aws_route53_record.blk_nlb_bastion_r53_record[0].fqdn : null
}
output "public_app_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? aws_route53_record.app_nlb_bastion_r53_record[0].fqdn : null
}
output "bastion_dns_entries_required_to_update" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env == "prod" && var.create_bastion_host ? local.dns_entries_list_prod : null
}
output "bastion_dns_entries_required_to_add" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env != "prod" && var.create_bastion_host ? local.dns_entries_list_non_prod : null
}
output "public_app_bastion_dns_name" {
  value = var.create_bastion_host ? module.app_bastion_nlb[0].lb_dns_name : null
}
output "public_blk_bastion_dns_name" {
  value = var.create_bastion_host ? module.blk_bastion_nlb[0].lb_dns_name: null
}
output "r53_public_hosted_zone_id" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_zone.zones[0].zone_id : null
}
output "r53_private_hosted_zone_id"{
  value = aws_route53_zone.aais_private_zones.zone_id
}
output "r53_private_hosted_zone_internal_id" {
  value = aws_route53_zone.aais_private_zones_internal.zone_id
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key related to vault unseal
output "kms_key_arn_vault_unseal_arn" {
  value = aws_kms_key.vault_kms_key.arn
}
output "kms_key_id_vault_unseal_name" {
  value = aws_kms_alias.vault_kms_key_alias.name
}