locals{
  common_tags = {
  Name = Terraform_ECS_Lab"

resource "aws_vpc" "apivpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags =  local.common_tags
}
