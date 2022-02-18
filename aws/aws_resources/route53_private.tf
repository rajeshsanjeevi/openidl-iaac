#creating private hosted zones for internal vpc dns resolution - databases and vault
resource "aws_route53_zone" "aais_private_zones_internal" {
  name    = "internal.${var.domain_info.domain_name}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = module.aais_app_vpc.vpc_id
  }
  vpc {
    vpc_id = module.aais_blk_vpc.vpc_id
  }
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-internal.${var.domain_info.domain_name}"
      "Cluster_type" = "both"
  },)
}
#creating private hosted zones for internal vpc dns resolution - others
resource "aws_route53_zone" "aais_private_zones" {
  name    = "${var.aws_env}.${var.domain_info.sub_domain_name}.${var.domain_info.domain_name}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = module.aais_app_vpc.vpc_id
  }
  vpc {
    vpc_id = module.aais_blk_vpc.vpc_id
  }
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-${var.domain_info.domain_name}"
      "Cluster_type" = "both"
  },)
}

