resource "aws_vpc" "meet_sheth_vpc" {
  cidr_block           = "10.123.0.0/16"
  tags = {
    Name = "meet_sheth_vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "public_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_subnet" "meetsheth_public" {
count   = 2
    vpc_id = aws_vpc.meet_sheth_vpc.id
    cidr_block = var.public_cidrs[count.index]
    availability_zone       = random_shuffle.public_az.result[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "meetsheth_public_${count.index + 1}"
    }
}

resource "aws_subnet" "meetsheth_private" {
count = 2
    vpc_id = aws_vpc.meet_sheth_vpc.id
    cidr_block = var.private_cidrs[count.index]
    availability_zone = random_shuffle.public_az.result[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name = "meetsheth_private_${count.index + 1}"
    }
}

resource "aws_route_table" "meet_public_rt" {
  vpc_id = aws_vpc.meet_sheth_vpc.id

  tags = {
    Name = "meet_public_rt"
  }
}

resource "aws_internet_gateway" "meet_internet_gateway" {
  vpc_id = aws_vpc.meet_sheth_vpc.id

  tags = {
    Name = "meet_igw"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.meet_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.meet_internet_gateway.id
}


resource "aws_default_route_table" "meet_private_rt" {
  default_route_table_id = aws_vpc.meet_sheth_vpc.default_route_table_id

  tags = {
    Name = "meet_private"
  }
}

resource "aws_route_table_association" "mtc_public_assoc" {
count = 2
  subnet_id      = aws_subnet.meetsheth_public.*.id[count.index]
  route_table_id = aws_route_table.meet_public_rt.id
}

resource "aws_security_group" "meet_public_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.meet_sheth_vpc.id



  #public Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}