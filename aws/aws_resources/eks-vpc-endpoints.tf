#application cluster(eks) vpc endpoints
resource "aws_vpc_endpoint" "app_eks_s3" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id       = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-s3-endpoint"
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
locals {
   app-count = var.create_vpc ? length(module.app_vpc[0].private_route_table_ids) : length(data.aws_route_tables.app_vpc_private_rt[0].ids)
   blk-count = var.create_vpc ? length(module.blk_vpc[0].private_route_table_ids) : length(data.aws_route_tables.blk_vpc_private_rt[0].ids)
}
resource "aws_vpc_endpoint_route_table_association" "app_eks_private_s3_route" {
  count           = var.cluster_endpoint_public_access == false ? local.app-count : 0
  vpc_endpoint_id = aws_vpc_endpoint.app_eks_s3[0].id
  route_table_id  = var.create_vpc ? module.app_vpc[0].private_route_table_ids[count.index] : tolist(data.aws_route_tables.app_vpc_private_rt[0].ids)[count.index]
  depends_on      = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ec2" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ec2-endpoint",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ecr_dkr" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ecr-dkr-endpoint",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_elb" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ec2-elb",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_asg" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ec2-asg",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_logs" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-logs",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_sts" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ec2-sts",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ecr_api" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.app_vpc[0].vpc_id : data.aws_vpc.app_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.app_vpc[0].private_subnets : data.aws_subnet_ids.app_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.app_cluster_name}-ecr-api",
    "cluster_type" = "application" })
  depends_on = [module.app_vpc]
}
#blockchain cluster (eks) vpc endpoints
resource "aws_vpc_endpoint" "blk_eks_s3" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id       = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-s3-endpoint"
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint_route_table_association" "blk_eks_private_s3_route" {
  count           = var.cluster_endpoint_public_access == false ? local.blk-count : 0
  vpc_endpoint_id = aws_vpc_endpoint.blk_eks_s3[0].id
  route_table_id  = var.create_vpc ? module.blk_vpc[0].private_route_table_ids[count.index] : tolist(data.aws_route_tables.blk_vpc_private_rt[0].ids)[count.index]
  depends_on      = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ec2" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ec2-endpoint",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ecr_dkr" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ecr-dkr-endpoint",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_elb" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ec2-elb",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_asg" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ec2-asg",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_logs" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-logs",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_sts" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ec2-sts",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ecr_api" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.blk_vpc[0].vpc_id : data.aws_vpc.blk_vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.blk_vpc[0].private_subnets : data.aws_subnet_ids.blk_vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.blk_cluster_name}-ecr-api",
    "cluster_type" = "blockchain" })
  depends_on = [module.blk_vpc]
}
