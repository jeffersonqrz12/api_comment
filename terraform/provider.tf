provider "aws" {
  region = "us-east-1"  # região da cloud
}

tls = {
      source  = "hashicorp/tls"
      version = "~> 2.0"  
    }
}
