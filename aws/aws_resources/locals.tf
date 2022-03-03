##local variables and their manipulation are here
locals {
  terraform_user_name = split("/", var.aws_user_arn)
  terraform_role_name = split("/", var.aws_role_arn)

  std_name          = "${substr(var.org_name,0,4)}-${var.aws_env}"
  app_cluster_name  = "${local.std_name}-${var.app_cluster_name}"
  blk_cluster_name  = "${local.std_name}-${var.blk_cluster_name}"
  policy_arn_prefix = "arn:aws:iam::aws:policy"

  tags = merge(var.custom_tags, {
    application = "openidl"
    environment = var.aws_env
    managed_by  = "terraform"
    node_type   = var.org_name
  })

  bastion_host_userdata = filebase64("resources/bootstrap-scripts/bastion_host.sh")
  worker_nodes_userdata = filebase64("resources/bootstrap-scripts/worker_nodes.sh")

  #sub domain specific
  public_domain = "${var.domain_info.sub_domain_name}" == "" ? "${var.domain_info.domain_name}" : "${var.domain_info.sub_domain_name}.${var.domain_info.domain_name}"
  private_domain = "${var.domain_info.sub_domain_name}" == "" ? "${var.domain_info.domain_name}" : "${var.domain_info.sub_domain_name}.${var.domain_info.domain_name}"

  #cognito custom attributes
  custom_attributes = [
    "role",
    "stateCode",
    "stateName",
    "organizationId"]

  app_def_sg_ingress = [{
    cidr_blocks = var.create_vpc ? var.app_vpc_cidr : data.aws_vpc.app_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  },
  {
    cidr_blocks = var.create_vpc ? var.app_vpc_cidr : data.aws_vpc.app_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
  },
  {
    cidr_blocks = var.create_vpc ? var.app_vpc_cidr : data.aws_vpc.app_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "8443"
    to_port     = "8443"
    protocol    = "tcp"
  }]

  blk_def_sg_ingress = [{
    cidr_blocks = var.create_vpc ? var.blk_vpc_cidr : data.aws_vpc.blk_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  },
  {
    cidr_blocks = var.create_vpc ? var.blk_vpc_cidr : data.aws_vpc.blk_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
  },
  {
    cidr_blocks = var.create_vpc ? var.blk_vpc_cidr : data.aws_vpc.blk_vpc[0].cidr_block
    description = "Inbound SSH traffic"
    from_port   = "8443"
    to_port     = "8443"
    protocol    = "tcp"
  }]
  def_sg_egress = [{
    cidr_blocks = "0.0.0.0/0"
    description = "Outbound SSH traffic"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
  },
  {
    cidr_blocks = "0.0.0.0/0"
    description = "Outbound SSH traffic"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
  },
  {
    cidr_blocks = "0.0.0.0/0"
    description = "Outbound SSH traffic"
    from_port   = "8443"
    to_port     = "8443"
    protocol    = "tcp"
  }]

  app_tgw_routes = [{destination_cidr_block = var.create_vpc ? var.blk_vpc_cidr : data.aws_vpc.blk_vpc[0].cidr_block}]
  blk_tgw_routes = [{destination_cidr_block = var.create_vpc ? var.app_vpc_cidr : data.aws_vpc.app_vpc[0].cidr_block}]
  app_tgw_destination_cidr = var.create_vpc ? ["${var.blk_vpc_cidr}"] : ["${data.aws_vpc.blk_vpc[0].cidr_block}"]
  blk_tgw_destination_cidr = var.create_vpc ? ["${var.app_vpc_cidr}"] : ["${data.aws_vpc.app_vpc[0].cidr_block}"]

  def_app_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = var.create_vpc ? "${var.app_vpc_cidr}" : "${data.aws_vpc.app_vpc[0].cidr_block}"}]
  def_app_bastion_sg_egress = [
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = var.create_vpc ? "${var.app_vpc_cidr}" : "${data.aws_vpc.app_vpc[0].cidr_block}"}]

  def_blk_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = var.create_vpc ? "${var.blk_vpc_cidr}" : "${data.aws_vpc.blk_vpc[0].cidr_block}"}]
  def_blk_bastion_sg_egress = [
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = var.create_vpc ? "${var.blk_vpc_cidr}" : "${data.aws_vpc.blk_vpc[0].cidr_block}"}]

  dns_entries_list_non_prod = var.create_bastion_host ? {
    "app-bastion.${var.aws_env}.${local.public_domain}" = module.app_bastion_nlb[0].lb_dns_name,
    "blk-bastion.${var.aws_env}.${local.public_domain}.${var.domain_info.domain_name}"= module.blk_bastion_nlb[0].lb_dns_name,
    } : {}

  dns_entries_list_prod = var.create_bastion_host ? {
    "app-bastion.${local.public_domain}" = module.app_bastion_nlb[0].lb_dns_name,
    "blk-bastion.${local.public_domain}" = module.blk_bastion_nlb[0].lb_dns_name,
  } : {}

  app_eks_control_plane_sg_computed_ingress = var.create_bastion_host ? [
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-1024-65535"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-443"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from bastion sg to eks control plane sg-1024-65535"
      source_security_group_id = module.app_bastion_sg[0].security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from bastion sg to eks control plane sg-443"
      source_security_group_id = module.app_bastion_sg[0].security_group_id
    }] : [
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-1024-65535"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-443"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
  }]

  blk_eks_control_plane_sg_computed_ingress = var.create_bastion_host ? [
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-1024-65535"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-443"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from bastion sg to eks control plane sg-1024-65535"
      source_security_group_id = module.blk_bastion_sg[0].security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from bastion sg to eks control plane sg-443"
      source_security_group_id = module.blk_bastion_sg[0].security_group_id
    }] : [
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-1024-65535"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from nodegroup sg to eks control plane sg-443"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
  }]

  app_eks_worker_node_group_sg_computed_ingress = var.create_bastion_host ? [
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-10250"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-443"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-1024-65535"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-443"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-1024-65535"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
  },
  {
      from_port                = 53
      to_port                  = 53
      protocol                 = "udp"
      description              = "Inbound from node group sg to node group sg-53"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
  },
  {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Inbound from bastion hosts sg to node group sg-22"
      source_security_group_id = module.app_bastion_sg[0].security_group_id
  }] : [
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-10250"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-443"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-1024-65535"
      source_security_group_id = module.app_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-443"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-1024-65535"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
  },
  {
      from_port                = 53
      to_port                  = 53
      protocol                 = "udp"
      description              = "Inbound from node group sg to node group sg-53"
      source_security_group_id = module.app_eks_worker_node_group_sg.security_group_id
  }]

  blk_eks_worker_node_group_sg_computed_ingress = var.create_bastion_host ? [
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-10250"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-443"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-1024-65535"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-443"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-1024-65535"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
  },
    {
      from_port                = 53
      to_port                  = 53
      protocol                 = "udp"
      description              = "Inbound from node group sg to node group sg-53"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
  },
  {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Inbound from bastion hosts sg to node group sg-22"
      source_security_group_id = module.blk_bastion_sg[0].security_group_id
  }] : [
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-10250"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-443"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from control plane sg to node group sg-1024-65535"
      source_security_group_id = module.blk_eks_control_plane_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-443"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
    },
    {
      from_port                = 1024
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Inbound from node group sg to node group sg-1024-65535"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
  },
    {
      from_port                = 53
      to_port                  = 53
      protocol                 = "udp"
      description              = "Inbound from node group sg to node group sg-53"
      source_security_group_id = module.blk_eks_worker_node_group_sg.security_group_id
  }]
}
