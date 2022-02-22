##Define required terraform and provider version
terraform {
  required_version = ">= 1.0.0" #change version to 1.0.5
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
 }

