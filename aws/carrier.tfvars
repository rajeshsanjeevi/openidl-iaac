#The following inputs should be via git secrets as they contain sensitive data. refer to README.md
##################start of sensitive data that goes to git secrets###################
aws_account_number = "572551282206" #mandatory
##aws_access_key = ""     #mandatory
##aws_secret_key = ""     #mandatory
aws_user_arn = "arn:aws:iam::572551282206:user/terraform_user"       #mandatory
aws_role_arn = "arn:aws:iam::572551282206:role/tf_automation"       #mandatory
aws_region = "us-east-2"         #mandatory
#aws_external_id = ""    #mandatory
app_bastion_ssh_key = "123"    #mandatory
blk_bastion_ssh_key = "123"    #mandatory
app_eks_worker_nodes_ssh_key = "123"   #mandatory
blk_eks_worker_nodes_ssh_key = "123"   #mandatory

#Cognito specifications
#When email_sending_account = "COGNITO_DEFAULT", set the below to empty in git secrets
#When email_sending_account = "DEVELOPER", setup verified email address in AWS SES on cognito supported region and update the below in git secrets
##ses_email_identity = "" #email address verified in AWS SES
##userpool_email_source_arn ="" #arn of the email address configured in aws SES service

#List of iam users and their relevant groups mapping in EKS for its access
#When no additional IAM users are required to enable EKS access, set the below as empty in git secrets
##app_cluster_map_users = ["<userarn>","<userarn>"] #Optional, if not required set to empty in git secrets
##app_cluster_map_roles = ["<rolearn>","<rolearn>"] #Optional, if not required set to emtpy in git secrets

#List of iam roles and their relevant group mapping in EKS for its access
#When no additional IAM roles are required to enable EKS access, set the below as empty in git secrets
##blk_cluster_map_users = ["<userarn>","<userarn>"] #Optional, if not required set to empty in git secrets
##blk_cluster_map_roles = ["<rolearn>","<rolearn>"] #Optional, if not required set to empty in git secrets

#Name of S3 bucket to hold terraform input file
##aws_input_bucket = ""

################end of sensitive data that goes to git secrets#####################

#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

org_name = "hig" #Its an example
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
#Application cluster VPC specifications
app_vpc_cidr           = "172.18.0.0/16"
app_availability_zones = ["us-east-2a", "us-east-2b"]
app_public_subnets     = ["172.18.1.0/24", "172.18.2.0/24"]
app_private_subnets    = ["172.18.3.0/24", "172.18.4.0/24"]

#-------------------------------------------------------------------------------------------------------------------
#Blockchain cluster VPC specifications
blk_vpc_cidr           = "172.19.0.0/16"
blk_availability_zones = ["us-east-2a", "us-east-2b"]
blk_public_subnets     = ["172.19.1.0/24", "172.19.2.0/24"]
blk_private_subnets    = ["172.19.3.0/24", "172.19.4.0/24"]

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specifications
#Bastion hosts are placed behind nlb. These NLBs can be configured to be private | public to serve SSH traffics.
#Either case whether NLB is private|public, the source ip_address|cidr_block should be enabled in bastion host's security group for incoming ssh traffic.
#in bastion hosts security group for ssh traffic

#when set to true bastion host's nlb is exposed as public, otherwise exposed only to internal to VPC
bastion_host_nlb_external = "true"

#application cluster bastion host specifications
app_bastion_sg_ingress =  [
    {rule="ssh-tcp", cidr_blocks = "172.18.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]
app_bastion_sg_egress =   [
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = "172.18.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]

#blockchain cluster bastion host specifications
#bastion host security specifications
blk_bastion_sg_ingress =  [
    {rule="ssh-tcp", cidr_blocks = "172.19.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]
blk_bastion_sg_egress =   [
    {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
    {rule="ssh-tcp", cidr_blocks = "172.19.0.0/16"},
    {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}
    ]

#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "yes" #Options: yes | no
  domain_name = "hig.aaisdirect.com", #primary domain registered
  sub_domain_name = "carrier" #sub domain
  comments = "hig carrier domain"
}

#-------------------------------------------------------------------------------------------------------------------
#Transit gateway  specifications
tgw_amazon_side_asn = "64532" #default is 64532

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
userpool_name                = "openidl-pool" #unique user_pool name
client_app_name              = "openidl-client" #a name of the application that uses user pool
client_callback_urls         = ["https://dev-carrier.hig.aaisdirect.com/callback", "https://dev-carrier.hig.aaisdirect.com/redirect"] #ensure to add redirect url part of callback urls, as this is required
client_default_redirect_url  = "https://dev-carrier.hig.aaisdirect.com/redirect" #redirect url
client_logout_urls           = ["https://dev-carrier.hig.aaisdirect.com/signout"] #logout url
cognito_domain               = "hig-aaisdirect" #unique domain name

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
    cidr_blocks = "172.18.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.19.0.0/16"
   }]
app_eks_workers_app_sg_egress = [{rule = "all-all"}]

#Any additional traffic required to open to worker nodes in future, below are required to set (blk cluster)
blk_eks_workers_app_sg_ingress = [
  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.18.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.19.0.0/16"
   }]
blk_eks_workers_app_sg_egress = [{rule = "all-all"}]

#--------------------------------------------------------------------------------------------------------------------
# application cluster EKS specifications
app_cluster_name              = "app-cluster"
app_cluster_version           = "1.20"
app_worker_nodes_ami_id = "ami-09fd0b5dd68327412"

#--------------------------------------------------------------------------------------------------------------------
# blockchain cluster EKS specifications
blk_cluster_name              = "blk-cluster"
blk_cluster_version           = "1.20"
blk_worker_nodes_ami_id = "ami-09fd0b5dd68327412"

#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
cw_logs_retention_period = "90" #example 90 days
s3_bucket_name_cloudtrail = "carrier-dev-hig-triallogs" #s3 bucket name to manage cloudtrail logs

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket managing terraform state files
#terraform_state_s3_bucket_name = "carrier-dev-hig-tfstate-backend"
tfc_org_name = "openidl-aais"
tfc_workspace_name_aws_resources = "hig-openidl-demo-aws-resources"

