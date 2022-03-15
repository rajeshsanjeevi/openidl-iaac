#Active below code snippet when used S3 as backend

#terraform {
#  backend "s3" {}
#}
#This code is when backend is TFC/TFE
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

