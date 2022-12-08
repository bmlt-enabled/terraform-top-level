terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }

  backend "s3" {
    bucket  = "mvana-account-terraform"
    key     = "top-level/state.json"
    region  = "us-east-1"
    profile = "mvana"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "mvana"
}

data "aws_elb_service_account" "main" {}

data "aws_acm_certificate" "bmltenabled_org" {
  domain      = "*.bmltenabled.org"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "aws_bmlt_app" {
  name = "aws.bmlt.app."
}

data "aws_secretsmanager_secret" "docker" {
  name = "docker"
}
