#uses s3 as backend to manage terraform state files
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openidl-aais"
    token = "XZqw2s5sXMUJbA.atlasv1.yuCQN8YovXBWWUhyBeMyiQW7uQjifocjEOIkvLz7xIQeeAzyYxA6FHZ8zQ7mnRmBRaU"
    workspaces {
      name = "aais-dev-aws-resources"
    }
  }
}
#terraform {
#  backend "s3" {}
#}