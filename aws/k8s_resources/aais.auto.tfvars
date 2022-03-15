#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

aws_account_number = ""
aws_access_key = ""
aws_secret_key = ""
aws_user_arn = ""
aws_role_arn = ""
aws_region = "us-east-2"
aws_external_id = "terraform"
bastion_ssh_key = ""
app_eks_worker_nodes_ssh_key = ""
blk_eks_worker_nodes_ssh_key = ""
ses_email_identity = ""
userpool_email_source_arn = ""

app_cluster_map_users = []
blk_cluster_map_users = []
app_cluster_map_roles = []
blk_cluster_map_roles = []

org_name = "aais" #Its an example
aws_env  = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
create_vpc = "false"
#key in VPC ids when create_vpc is false
vpc_id = "vpc-0abf6170667972e95"

#Key in inputs for the below when create_vpc is true
vpc_cidr = "172.18.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnets = ["172.18.1.0/24", "172.18.2.0/24", "172.18.5.0/24"]
private_subnets = ["172.18.3.0/24", "172.18.4.0/24", "172.18.6.0/24"]

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specifications
#Bastion hosts are placed behind nlb.
#The source ip_address|cidr_block should be enabled in bastion host's security group for incoming ssh traffic.
#in bastion hosts security group for ssh traffic

create_bastion_host = "true"
bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
bastion_sg_egress =   [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]

#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "yes" #Options: yes | no
  domain_name = "thetech.digital", #primary domain registered
  sub_domain_name = "" #sub domain optional
  comments = "aais-dev node domain"
}

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
create_cognito_userpool = "true"
userpool_name = "openidl-pool-test" #unique user_pool name

# COGNITO_DEFAULT - Uses cognito default. When set to cognito default SES related inputs goes empty in git secrets
# DEVELOPER - Ensure inputs ses_email_identity and userpool_email_source_arn are setup in git secrets
email_sending_account = "COGNITO_DEFAULT" # Options: COGNITO_DEFAULT | DEVELOPER

#--------------------------------------------------------------------------------------------------------------------
# application cluster EKS specifications
app_cluster_name = "app-cluster"
app_cluster_version = "1.20"
app_worker_nodes_ami_id = "ami-09fd0b5dd68327412"

#--------------------------------------------------------------------------------------------------------------------
# blockchain cluster EKS specifications
blk_cluster_name = "blk-cluster"
blk_cluster_version = "1.20"
blk_worker_nodes_ami_id = "ami-09fd0b5dd68327412"

#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
create_cloudtrail = "true"
s3_bucket_name_cloudtrail = "openidl-cloudtrail" #s3 bucket name to manage cloudtrail logs

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket managing terraform state files - applicable when backend is S3
terraform_state_s3_bucket_name = ""

#Applicable when backend environment is Terraform Cloud/Enterprise
tfc_org_name = "openidl-aais"
tfc_workspace_name_aws_resources = "aais-dev-aws-resources"

#Name of the S3 bucket used to store the data extracted from HDS for analytics
s3_bucket_name_hds_analytics = "openidl-hdsdata"

#Name of the S3 bucket used to store images(logos/icons)
create_s3_bucket_public = "true"
s3_bucket_name_logos = "openidl-public-logos"

#Name of the S3 bucket to store access logs of S3 buckets and its objects
s3_bucket_name_access_logs = "access-logs"

#KMS Key arn to be used when create_kms_keys is set to false
create_kms_keys = "true"
s3_kms_key_arn = "arn:aws:kms:us-east-2:357396431244:key/2beec660-bc74-4a26-add4-12d9918d5efb"
eks_kms_key_arn = "arn:aws:kms:us-east-2:357396431244:key/2beec660-bc74-4a26-add4-12d9918d5efb"
cloudtrail_cw_logs_kms_key_arn = "arn:aws:kms:us-east-2:357396431244:key/2beec660-bc74-4a26-add4-12d9918d5efb"
vpc_flow_logs_kms_key_arn = "arn:aws:kms:us-east-2:357396431244:key/2beec660-bc74-4a26-add4-12d9918d5efb"
secrets_manager_kms_key_arn = "arn:aws:kms:us-east-2:357396431244:key/2beec660-bc74-4a26-add4-12d9918d5efb"
#Finally look into EBS volume kms key

#Cloudwatch logs retention period (VPC Flow logs, EKS Logs and Cloudtrail Logs)
cw_logs_retention_period = "90" #example 90 days

#Custom tags - any set of key:value pairs to be included part of tags.
custom_tags = {
  custom_key1 = "custom_value1"
  custom_key2 = "custom_value2"
}
