
resource "aws_subnet" "private_tf_subnet" {
  count             = 3
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.terraform_vpc.cidr_block, 3, count.index + 3)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_route_table" "private_tf_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_tf_gateway.id
  }
}
resource "aws_route_table_association" "private_tf_route_table_association" {
  count          = 3
  subnet_id      = element(aws_subnet.private_tf_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_tf_route_table.id
}

output "private_subnets" {
  value = aws_subnet.private_tf_subnet[*].id
}