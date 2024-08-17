# Subnet pública na zona us-east-1a
resource "aws_subnet" "apisub_publica" {
  vpc_id                  = aws_vpc.apivpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = local_common_tags
}

# Subnet pública na zona us-east-1b
resource "aws_subnet" "apisub_publicb" {
  vpc_id                  = aws_vpc.apivpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = local.common_tags
}
