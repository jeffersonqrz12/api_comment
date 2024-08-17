# Criar uma tabela de rotas
resource "aws_route_table" "api_route" {
  vpc_id = aws_vpc.apivpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.api_gateway.id
  }
}

# Associar a tabela de rotas às subnets
resource "aws_route_table_association" "publica_association" {
  subnet_id      = aws_subnet.apisub_publica.id
  route_table_id = aws_route_table.api_route.id
}
