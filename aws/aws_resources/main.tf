#uses s3 as backend to manage terraform state files
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = "gMO9mrysiep9cg.atlasv1.R05mX7aQQr4ECIFUqKKHfgTVjQcOeiheec72HAX8kNTJ6nIRUZz7zJ6ArU9qsJuPYu0"
    workspaces {
      name = "aais-dev-aws-resources"
    }
  }
}
#terraform {
#  backend "s3" {}
#}