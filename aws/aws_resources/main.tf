#uses s3 as backend to manage terraform state files
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = ""
    workspaces {
      name = "aais-dev-aws-resources"
    }
  }
}
#terraform {
#  backend "s3" {}
#}
