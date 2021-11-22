#uses s3 as backend to manage terraform state files
#terraform {
#  backend "s3" {}
#}
terraform {
  backend "local" {}
}
