#creating private hosted zones for internal vpc dns resolution - databases and vault
resource "aws_route53_zone" "aais_private_zones_internal" {
  name    = "internal.${var.domain_info.domain_name}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = var.create_vpc ? module.aais_app_vpc.vpc_id : data.aws_vpc.app_vpc.id
  }
  vpc {
    vpc_id = var.create_vpc ? module.aais_blk_vpc.vpc_id : data.aws_vpc.blk_vpc.id
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-internal.${var.domain_info.domain_name}"
      "cluster_type" = "both"
  },)
}
#creating private hosted zones for internal vpc dns resolution - others
resource "aws_route53_zone" "aais_private_zones" {
  name    = "${var.aws_env}.${local.private_domain}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = var.create_vpc ? module.aais_app_vpc.vpc_id : data.aws_vpc.app_vpc.id
  }
  vpc {
    vpc_id = var.create_vpc ? module.aais_blk_vpc.vpc_id : data.aws_vpc.blk_vpc.id
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-${var.domain_info.domain_name}"
      "cluster_type" = "both"
  },)
}

