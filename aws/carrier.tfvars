#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

org_name = "carrier" #Its an example
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
#Application cluster VPC specifications
app_vpc_cidr           = "172.22.0.0/16"
app_availability_zones = ["us-west-1a", "us-west-1b"]
app_public_subnets     = ["172.22.1.0/24", "172.22.2.0/24"]
app_private_subnets    = ["172.22.3.0/24", "172.22.4.0/24"]

#-------------------------------------------------------------------------------------------------------------------
#Blockchain cluster VPC specifications
blk_vpc_cidr           = "172.23.0.0/16"
blk_availability_zones = ["us-west-1a", "us-west-1b"]
blk_public_subnets     = ["172.23.1.0/24", "172.23.2.0/24"]
blk_private_subnets    = ["172.23.3.0/24", "172.23.4.0/24"]

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specifications
#Bastion hosts are placed behind nlb. These NLBs can be configured to be private | public to serve SSH traffics.
#Either case whether NLB is private|public, the source ip_address|cidr_block should be enabled in bastion host's security group for incoming ssh traffic.
#in bastion hosts security group for ssh traffic

#when set to true bastion host's nlb is exposed as public, otherwise exposed only to internal to VPC
bastion_host_nlb_external = "true"

#application cluster bastion host specifications
app_bastion_sg_ingress =  [
    {rule="ssh-tcp", cidr_blocks = "172.22.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]
app_bastion_sg_egress =   [
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = "172.22.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]

#blockchain cluster bastion host specifications
#bastion host security specifications
blk_bastion_sg_ingress =  [
    {rule="ssh-tcp", cidr_blocks = "172.23.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]
blk_bastion_sg_egress =   [
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = "172.23.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]

#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "yes" #Options: yes | no
  domain_name = "thetech.digital", #primary domain registered
  sub_domain_name = "carrier" #sub domain
  comments = "carrier node domain"
}

#-------------------------------------------------------------------------------------------------------------------
#Transit gateway  specifications
tgw_amazon_side_asn = "64532" #default is 64532

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
userpool_name                = "openidl-pool-carr" #unique user_pool name
client_app_name              = "openidl-client-carr" #a name of the application that uses user pool
client_callback_urls         = ["https://dev-carrier.hig.aaisdirect.com/callback", "https://dev-carrier.hig.aaisdirect.com/redirect"] #ensure to add redirect url part of callback urls, as this is required
client_default_redirect_url  = "https://dev-carrier.hig.aaisdirect.com/redirect" #redirect url
client_logout_urls           = ["https://dev-carrier.hig.aaisdirect.com/signout"] #logout url
cognito_domain               = "carr-openidl" #unique domain name

# COGNITO_DEFAULT - Uses cognito default. When set to cognito default SES related inputs goes empty in git secrets
# DEVELOPER - Ensure inputs ses_email_identity and userpool_email_source_arn are setup in git secrets
email_sending_account        = "COGNITO_DEFAULT" # Options: COGNITO_DEFAULT | DEVELOPER

#--------------------------------------------------------------------------------------------------------------------
#Any additional traffic required to open to worker nodes in future, below are required to set (app cluster)
app_eks_workers_app_sg_ingress = [
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.22.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.23.0.0/16"
   }]
app_eks_workers_app_sg_egress = [{rule = "all-all"}]

#Any additional traffic required to open to worker nodes in future, below are required to set (blk cluster)
blk_eks_workers_app_sg_ingress = [
  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.22.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.23.0.0/16"
   }]
blk_eks_workers_app_sg_egress = [{rule = "all-all"}]

#--------------------------------------------------------------------------------------------------------------------
# application cluster EKS specifications
app_cluster_name              = "app-cluster"
app_cluster_version           = "1.20"
app_worker_nodes_ami_id = "ami-02da3146d735616ea"

#--------------------------------------------------------------------------------------------------------------------
# blockchain cluster EKS specifications
blk_cluster_name              = "blk-cluster"
blk_cluster_version           = "1.20"
blk_worker_nodes_ami_id = "ami-02da3146d735616ea"

#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
cw_logs_retention_period = "90" #example 90 days
s3_bucket_name_cloudtrail = "carr-dev-env-trial-logs" #s3 bucket name to manage cloudtrail logs

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket managing terraform state files - applicable when backend is S3
#terraform_state_s3_bucket_name = "carrier-dev-hig-tfstate-backend"

#Applicable when backend environment is Terraform Cloud/Enterprise
tfc_org_name = "openidl-aais"
tfc_workspace_name_aws_resources = "openidl-carr-aws-resources"

##Name of the S3 bucket used to store the data extracted from HDS for analytics
s3_bucket_name_hds_analytics = "openidl-hds-analytics-data"
s3_bucket_name_logos_public = "demo-data-logos"
