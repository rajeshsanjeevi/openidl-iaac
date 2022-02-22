#creating public hosted zones
resource "aws_route53_zone" "zones" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  name    = lookup(var.domain_info, "domain_name")
  comment = lookup(var.domain_info, "comments", null)
  tags = merge(
    local.tags,
    {
      "name"         = "${var.domain_info.domain_name}"
      "cluster_type" = "Both"
  }, )
}
#setting dns entry for bastion host in app cluster vpc
resource "aws_route53_record" "app_nlb_bastion_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? 1 : 0
  zone_id = aws_route53_zone.zones[0].id
  name    = var.aws_env != "prod" ? "app-bastion.${var.aws_env}.${local.public_domain}" : "app-bastion.${local.public_domain}"
  type    = "A"
  alias {
    name                   = module.app_bastion_nlb[0].lb_dns_name
    zone_id                = module.app_bastion_nlb[0].lb_zone_id
    evaluate_target_health = true
  }
}
#setting dns entry for bastion host in blk cluster vpc
resource "aws_route53_record" "blk_nlb_bastion_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? 1 : 0
  zone_id = aws_route53_zone.zones[0].id
  name    = var.aws_env != "prod" ? "blk-bastion.${var.aws_env}.${local.public_domain}" : "blk-bastion.${local.public_domain}"
  type    = "A"
  alias {
    name                   = module.blk_bastion_nlb[0].lb_dns_name
    zone_id                = module.blk_bastion_nlb[0].lb_zone_id
    evaluate_target_health = true
  }
}
