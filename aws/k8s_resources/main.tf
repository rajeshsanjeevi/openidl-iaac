#Active below code snippet when used S3 as backend

#terraform {
#  backend "s3" {}
#}
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = ""
    workspaces {
      name = "aais-dev-k8s-resources"
    }
  }
}

