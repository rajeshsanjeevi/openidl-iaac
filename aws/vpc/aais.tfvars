#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

aws_account_number = "357396431244"
aws_access_key = "AKIAVGNT4YGGON7FBX7P"
aws_secret_key = "wibcOCIBcy7562HEAdMb9z4zyTGpgzTGD/51CgGC"
#aws_access_key = ""
#aws_secret_key = ""
aws_user_arn = "arn:aws:iam::357396431244:user/terraform_dev_user"
aws_role_arn = "arn:aws:iam::357396431244:role/tf_dev_automation"
aws_region = "us-east-2"
aws_external_id = "terraform"
app_bastion_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJTI6JSWyleIzZhyBY2cRj92csqiGMTtg+dFjL5OvbInBibmvDDND7DKIyUfvEITBnxKicxWzZBOxFm5HrQMQWfGrszbDT3f+g/sWrCKcwOm4wWNGf/JjTVnCP1DopFmBzAYJ+JYJ3DMTnl261SPjV9HtTtXe/xzBrJIVMAKdO6KUWmF8q7x25Gq9GmrJmoEmqv6XxAqMYS90bGqdsxTsJwjh6yU3jKyhQBazmO4aEzscaNELXM/X52zcDulYa0ulQ2hJ0B72D/TmCJAJK7qkQ77qDcpvByKnaxcl+7aVQvcRYfOv0jYDAEyZb0hT3LSkEjuBwJnsJU26urHFCEBoDXg4+lwFL/UA/ofEfZbC18LbpVTCjhxQgIyVo6f5mcp+lzRSdPeTR+RMXnwecQHJjkG9Gl76M2uPbeIMt17PExASVdb6sl16qtMmGAKlP4RqZfI/HuZkeI8mdWiap9J/HUsn+Dq9JPq88yKtR7/Vxj1XSGbmaq15sONsAmBnjPHE= rajesh.sanjeevi@T480s-12"
blk_bastion_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJTI6JSWyleIzZhyBY2cRj92csqiGMTtg+dFjL5OvbInBibmvDDND7DKIyUfvEITBnxKicxWzZBOxFm5HrQMQWfGrszbDT3f+g/sWrCKcwOm4wWNGf/JjTVnCP1DopFmBzAYJ+JYJ3DMTnl261SPjV9HtTtXe/xzBrJIVMAKdO6KUWmF8q7x25Gq9GmrJmoEmqv6XxAqMYS90bGqdsxTsJwjh6yU3jKyhQBazmO4aEzscaNELXM/X52zcDulYa0ulQ2hJ0B72D/TmCJAJK7qkQ77qDcpvByKnaxcl+7aVQvcRYfOv0jYDAEyZb0hT3LSkEjuBwJnsJU26urHFCEBoDXg4+lwFL/UA/ofEfZbC18LbpVTCjhxQgIyVo6f5mcp+lzRSdPeTR+RMXnwecQHJjkG9Gl76M2uPbeIMt17PExASVdb6sl16qtMmGAKlP4RqZfI/HuZkeI8mdWiap9J/HUsn+Dq9JPq88yKtR7/Vxj1XSGbmaq15sONsAmBnjPHE= rajesh.sanjeevi@T480s-12"
app_eks_worker_nodes_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJTI6JSWyleIzZhyBY2cRj92csqiGMTtg+dFjL5OvbInBibmvDDND7DKIyUfvEITBnxKicxWzZBOxFm5HrQMQWfGrszbDT3f+g/sWrCKcwOm4wWNGf/JjTVnCP1DopFmBzAYJ+JYJ3DMTnl261SPjV9HtTtXe/xzBrJIVMAKdO6KUWmF8q7x25Gq9GmrJmoEmqv6XxAqMYS90bGqdsxTsJwjh6yU3jKyhQBazmO4aEzscaNELXM/X52zcDulYa0ulQ2hJ0B72D/TmCJAJK7qkQ77qDcpvByKnaxcl+7aVQvcRYfOv0jYDAEyZb0hT3LSkEjuBwJnsJU26urHFCEBoDXg4+lwFL/UA/ofEfZbC18LbpVTCjhxQgIyVo6f5mcp+lzRSdPeTR+RMXnwecQHJjkG9Gl76M2uPbeIMt17PExASVdb6sl16qtMmGAKlP4RqZfI/HuZkeI8mdWiap9J/HUsn+Dq9JPq88yKtR7/Vxj1XSGbmaq15sONsAmBnjPHE= rajesh.sanjeevi@T480s-12"
blk_eks_worker_nodes_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJTI6JSWyleIzZhyBY2cRj92csqiGMTtg+dFjL5OvbInBibmvDDND7DKIyUfvEITBnxKicxWzZBOxFm5HrQMQWfGrszbDT3f+g/sWrCKcwOm4wWNGf/JjTVnCP1DopFmBzAYJ+JYJ3DMTnl261SPjV9HtTtXe/xzBrJIVMAKdO6KUWmF8q7x25Gq9GmrJmoEmqv6XxAqMYS90bGqdsxTsJwjh6yU3jKyhQBazmO4aEzscaNELXM/X52zcDulYa0ulQ2hJ0B72D/TmCJAJK7qkQ77qDcpvByKnaxcl+7aVQvcRYfOv0jYDAEyZb0hT3LSkEjuBwJnsJU26urHFCEBoDXg4+lwFL/UA/ofEfZbC18LbpVTCjhxQgIyVo6f5mcp+lzRSdPeTR+RMXnwecQHJjkG9Gl76M2uPbeIMt17PExASVdb6sl16qtMmGAKlP4RqZfI/HuZkeI8mdWiap9J/HUsn+Dq9JPq88yKtR7/Vxj1XSGbmaq15sONsAmBnjPHE= rajesh.sanjeevi@T480s-12"
ses_email_identity = ""
userpool_email_source_arn = ""
app_cluster_map_users = []
blk_cluster_map_users = []
app_cluster_map_roles = []
blk_cluster_map_roles = []


org_name = "aais" #Its an example
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
create_vpc = "true"

vpc_cidr           = "172.18.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnets     = ["172.18.1.0/24", "172.18.2.0/24", "172.18.5.0/24"]
private_subnets    = ["172.18.3.0/24", "172.18.4.0/24", "172.18.6.0/24"]
