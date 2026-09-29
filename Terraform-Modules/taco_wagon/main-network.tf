# VPC Resources

data "aws_availability_zones" "available" {
  state = "available"
}

# NETWORKING #
/*
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_address_range
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

}

resource "aws_subnet" "public_subnets" {
  count = length(var.vpc_public_subnet_ranges)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnet_ranges[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  }
}

# ROUTING #
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(var.vpc_public_subnet_ranges)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.default.id
}
*/

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "${var.prefix}-vpc" #"my-vpc"
  cidr = var.vpc_address_range          # terraform.tfvars
  
  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.vpc_public_subnet_ranges))
                    #["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  #private_subnets = var.vpc_private_subnet_ranges #["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = var.vpc_public_subnet_ranges #["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false #true
  enable_vpn_gateway = false#true
  enable_dns_hostnames = true

  #tags = local.common_tags
}
