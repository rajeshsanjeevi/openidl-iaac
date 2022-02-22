##local variables and their manipulation are here
locals {
  std_name          = "${substr(var.org_name,0,4)}-${var.aws_env}"
  app_cluster_name  = "${local.std_name}-${var.app_cluster_name}"
  blk_cluster_name  = "${local.std_name}-${var.blk_cluster_name}"
  policy_arn_prefix = "arn:aws:iam::aws:policy"
  tags = {
    application = "openidl"
    environment = var.aws_env
    managed_by  = "terraform"
    node_type   = var.org_name
  }
  app_tgw_routes = [{destination_cidr_block = var.blk_vpc_cidr}]
  blk_tgw_routes = [{destination_cidr_block = var.app_vpc_cidr}]
  app_tgw_destination_cidr = ["${var.blk_vpc_cidr}"]
  blk_tgw_destination_cidr = ["${var.app_vpc_cidr}"]
}
