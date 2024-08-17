resource "aws_internet_gateway" "api_gateway" {
  vpc_id = aws_vpc.apivpc.id
  tags =  local.common_tags
}
