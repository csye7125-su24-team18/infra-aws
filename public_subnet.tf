
resource "aws_subnet" "public_tf_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.terraform_vpc.cidr_block, 3, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_tf_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
}

resource "aws_route_table_association" "public_tf_route_table_association" {
  count          = 3
  subnet_id      = element(aws_subnet.public_tf_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_tf_route_table.id
}

resource "aws_nat_gateway" "nat_tf_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_tf_subnet[0].id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

output "public_subnets" {
  value = aws_subnet.public_tf_subnet[*].id
}