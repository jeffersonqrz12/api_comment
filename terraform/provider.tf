terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0" 
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 2.0"  
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}
