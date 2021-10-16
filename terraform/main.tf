terraform {
  backend "s3" {
    bucket = "hi1280-tfstate-main"
    key    = "flask-example.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}
