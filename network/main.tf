# create a new VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name             = var.name
    Environment      = var.env
    TerraformManaged = "true"
  }
}

data "aws_availability_zones" "main" {
  state = "available"
}

# public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = data.aws_availability_zones.main.names[count.index % length(data.aws_availability_zones.main.names)]
  map_public_ip_on_launch = true

  tags = {
    Name             = "${var.name}-${format("public-subnet-%03d", count.index + 1)}"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = data.aws_availability_zones.main.names[count.index % length(data.aws_availability_zones.main.names)]

  tags = {
    Name             = "${var.name}-${format("private-subnet-%03d", count.index + 1)}"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# RDS Private Subnets
resource "aws_subnet" "rds" {
  count             = length(var.rds_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.rds_subnets, count.index)
  availability_zone = data.aws_availability_zones.main.names[count.index % length(data.aws_availability_zones.main.names)]
  tags = {
    Name             = "${var.name}-${format("rds-subnet-%03d", count.index + 1)}"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name             = "${var.name}-IGW"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name             = "${var.name}-public-RT"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name             = "${var.name}-private-RT"
    Environment      = var.env
    TerraformManaged = "true"
  }
}

# route to internet
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# associate subnets to route tables
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

