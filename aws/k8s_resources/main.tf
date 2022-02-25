#Active below code snippet when used S3 as backend

#terraform {
#  backend "local" {}
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

