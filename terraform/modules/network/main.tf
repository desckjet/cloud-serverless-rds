locals {
  module_tags = merge(
    var.tags,
    {
      Module = "network"
    }
  )

  # To determine how many AZs to use, we take the maximum number of subnets (public or private)
  # and then limit that to the number of available AZs in the region.
  # This ensures we do not try to create more subnets than AZs.
  subnet_count = max(length(var.public_subnet_cidrs), length(var.private_subnet_cidrs))
  az_count     = min(length(data.aws_availability_zones.available.names), local.subnet_count)

  # Create a list of AZs to use based on the count determined above
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    local.az_count
  )

  # Create key/value maps of subnet CIDRs with string keys for easier iteration
  public_subnet_map  = { for idx, cidr in var.public_subnet_cidrs : tostring(idx) => cidr }
  private_subnet_map = { for idx, cidr in var.private_subnet_cidrs : tostring(idx) => cidr }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(each.key) % local.az_count]
  map_public_ip_on_launch = true

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = local.azs[tonumber(each.key) % local.az_count]

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-nat-${each.key}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.this.id

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_nat" {
  for_each = aws_nat_gateway.nat

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = aws_subnet.private[each.key].id
  # Associate the private route table with the NAT gateway in a round-robin fashion
  route_table_id = aws_route_table.private[tostring(tonumber(each.key) % length(aws_route_table.private))].id
}

resource "aws_security_group" "shared" {
  name   = "${var.name_prefix}-default-sg"
  vpc_id = aws_vpc.this.id

  description = "Shared security group for Lambda and database components"

  egress {
    description = "Allow all outbound traffic from private workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-sg"
  })
}
