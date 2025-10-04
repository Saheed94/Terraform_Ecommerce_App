resource "aws_vpc" "mycustom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.mycustom_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags = { Name = "${var.name}-public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.mycustom_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az
  tags = { Name = "${var.name}-private-subnet" }
}

resource "aws_internet_gateway" "mycustom_vpc" {
  vpc_id = aws_vpc.mycustom_vpc.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mycustom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mycustom_vpc.id
  }
  tags = { Name = "${var.name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
