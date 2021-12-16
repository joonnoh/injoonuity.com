# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_dynamodb_table" "MyTable" {
  name         = var.MyTable_name
  billing_mode = var.MyTable_billing_mode
  hash_key     = "ItemName"
  attribute {
    name = "ItemName"
    type = "S"
  }
  tags = {
    environment = var.MyTable_environment
  }
}
