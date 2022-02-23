#Active below code snippet when used S3 as backend

#terraform {
#  backend "local" {}
#}
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = "XZqw2s5sXMUJbA.atlasv1.yuCQN8YovXBWWUhyBeMyiQW7uQjifocjEOIkvLz7xIQeeAzyYxA6FHZ8zQ7mnRmBRaU"
    workspaces {
      name = "aais-dev-k8s-resources"
    }
  }
}

