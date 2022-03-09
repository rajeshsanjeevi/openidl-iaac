#Active below code snippet when used S3 as backend

#terraform {
#  backend "s3" {}
#}
#This code is when backend is TFC/TFE
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = "gMO9mrysiep9cg.atlasv1.R05mX7aQQr4ECIFUqKKHfgTVjQcOeiheec72HAX8kNTJ6nIRUZz7zJ6ArU9qsJuPYu0"
    workspaces {
      name = "aais-dev-k8s-resources"
    }
  }
}

