# Learn our public IP address
data "http" "icanhazip" {
  url = "https://icanhazip.com"
}

resource "aws_vpc" "spendv" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${local.tags.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnets" {
  count             = var.public_subnets
  vpc_id            = aws_vpc.spendv.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[(count.index % length(data.aws_availability_zones.available.names))]

  tags = {
    Name = "${local.tags.prefix}-subnet${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.create_private_subnets == true ? var.private_subnets : 0
  vpc_id            = aws_vpc.spendv.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, (count.index + var.private_subnets_newbits))
  availability_zone = data.aws_availability_zones.available.names[(count.index % length(data.aws_availability_zones.available.names))]

  tags = {
    Name = "${local.tags.prefix}-subnet${(count.index + var.private_subnets_newbits)}"
  }
}

resource "aws_internet_gateway" "spendv" {
  vpc_id = aws_vpc.spendv.id

  tags = {
    Name = "${local.tags.prefix}-igw"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.spendv.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.spendv.id
  }

  tags = {
    Name = "${local.tags.prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = var.public_subnets
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.spendv.id

  tags = {
    Name = "${local.tags.prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count          = var.private_subnets
  route_table_id = aws_route_table.private_subnets.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_security_group" "public_instances" {
  name        = "${local.tags.prefix}-public-sg"
  description = "${local.tags.prefix}-public-sg"
  vpc_id      = aws_vpc.spendv.id

  tags = {
    Name = "${local.tags.prefix}-public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_allow_ssh" {
  security_group_id = aws_security_group.public_instances.id
  cidr_ipv4         = "${(chomp(data.http.icanhazip.response_body))}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "allow_ssh_from_home"
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_connect_allow_ssh" {
  security_group_id = aws_security_group.public_instances.id
  cidr_ipv4         = "18.206.107.24/29"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

  tags = {
    Name = "allow_ssh_instance_connect"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp" {
  security_group_id = aws_security_group.public_instances.id
  cidr_ipv4         = var.cidr_block
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
}

resource "aws_security_group" "private_instances" {
  name        = "${local.tags.prefix}-private-sg"
  description = "${local.tags.prefix}-private-sg"
  vpc_id      = aws_vpc.spendv.id

  tags = {
    Name = "${local.tags.prefix}-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  security_group_id = aws_security_group.private_instances.id
  cidr_ipv4         = var.cidr_block
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0

  tags = {
    Name = "allow_icmp"
  }
}