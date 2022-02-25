#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

aws_account_number = ""
aws_access_key = ""
aws_secret_key = ""
aws_user_arn = "arn:aws:iam:::user/terraform_dev_user"
aws_role_arn = "arn:aws:iam:::role/tf_dev_automation"
aws_region = "us-east-2"
aws_external_id = "terraform"
app_bastion_ssh_key = ""
blk_bastion_ssh_key = ""
app_eks_worker_nodes_ssh_key = ""
blk_eks_worker_nodes_ssh_key = ""
ses_email_identity = ""
userpool_email_source_arn = ""
app_cluster_map_users = []
blk_cluster_map_users = []
app_cluster_map_roles = []
blk_cluster_map_roles = []

org_name = "aais" #Its an example
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
create_vpc = "false"
#Application cluster VPC specifications
#key in VPC ids when create_vpc is false
app_vpc_id = "vpc-0b768c6cfb07f8cba"
blk_vpc_id = "vpc-0d3477e8efbb93293"

#Key in inputs for the below when create_vpc is true
#app_vpc_cidr           = "172.18.0.0/16"
#app_availability_zones = ["us-east-2a", "us-east-2b"]
#app_public_subnets     = ["172.18.1.0/24", "172.18.2.0/24"]
#app_private_subnets    = ["172.18.3.0/24", "172.18.4.0/24"]

#-------------------------------------------------------------------------------------------------------------------
#Blockchain cluster VPC specifications
#Key in inputs for the below when create_vpc is true
#blk_vpc_cidr           = "172.19.0.0/16"
#blk_availability_zones = ["us-east-2a", "us-east-2b"]
#blk_public_subnets     = ["172.19.1.0/24", "172.19.2.0/24"]
#blk_private_subnets    = ["172.19.3.0/24", "172.19.4.0/24"]

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specifications
#Bastion hosts are placed behind nlb.
#The source ip_address|cidr_block should be enabled in bastion host's security group for incoming ssh traffic.
#in bastion hosts security group for ssh traffic

create_bastion_host = "true"

#application cluster bastion host specifications
app_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
app_bastion_sg_egress =   [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"},{rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"}]

#blockchain cluster bastion host specifications
#bastion host security specifications
blk_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
blk_bastion_sg_egress =   [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"},{rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"}]
#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "yes" #Options: yes | no
  domain_name = "thetech.digital", #primary domain registered
  sub_domain_name = "aais" #sub domain optional
  comments = "aais node domain"
}

#-------------------------------------------------------------------------------------------------------------------
#Transit gateway  specifications
tgw_amazon_side_asn = "64532" #default is 64532

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
create_cognito_userpool = "true"
userpool_name                = "openidl-pool" #unique user_pool name
client_app_name              = "openidl-client" #name of the application client
client_callback_urls         = ["https://openidl-dev-aais.thetech.digital/callback", "https://openidl-dev-aais.thetech.digital/redirect"] #ensure to add redirect url part of callback urls, as this is required
client_default_redirect_url  = "https://openidl-dev-aais.thetech.digital/redirect" #redirect url
client_logout_urls           = ["https://openidl-dev-aais.thetech.digital/signout"] #logout url
cognito_domain               = "aais-openidl" #unique domain name

# COGNITO_DEFAULT - Uses cognito default. When set to cognito default SES related inputs goes empty in git secrets
# DEVELOPER - Ensure inputs ses_email_identity and userpool_email_source_arn are setup in git secrets
email_sending_account        = "COGNITO_DEFAULT" # Options: COGNITO_DEFAULT | DEVELOPER

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
create_cloudtrial = "true"
cw_logs_retention_period = "90" #example 90 days
s3_bucket_name_cloudtrail = "openidl-cloudtrial-logs" #s3 bucket name to manage cloudtrail logs

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket managing terraform state files - applicable when backend is S3
terraform_state_s3_bucket_name = ""

#Applicable when backend environment is Terraform Cloud/Enterprise
tfc_org_name = "openidl-aais"
tfc_workspace_name_aws_resources = "aais-dev-aws-resources"

#Name of the S3 bucket used to store the data extracted from HDS for analytics
s3_bucket_name_hds_analytics = "openidl-hds-analytics"

#Name of the S3 bucket used to store images(logos/icons)
create_s3_bucket_public = "true"
s3_bucket_name_logos = "openidl-public-logos"

#KMS Key arn to be used when create_kms_keys is set to false
create_kms_keys = "false"
s3_kms_key_arn = ""
eks_secrets_kms_key_arn = ""
eks_cwlogs_kms_key_arn = ""
cloudtrail_cwlogs_kms_key_arn = ""

#Custom tags to include
custom_tags = {
  custom_tag1 = "customtag1"
  custom_tag2 = "customtag2"
}
