# vpc iac 会在一个特定的ragion中建立一个除了默认vpc外的vpc，并建立2对子网（subnet for ecs/ec2）（subnet for redis & rds etc.）
#两对子网中，需要在ec2/ecs子网中绑定一个internet gataway保证 ec2和ecs中的instance能正常通过ssh访问（双向nat）
#并配置路由表，其中ec2/ecs子网的路由表绑定一个internet gatway，rds中只绑定private子网。
locals {
  inside_subnets = {
    inside_subnet1 = {
      "inside_subnet_cidr" = var.inside_net_cidr1  #"10.1.101.0/24"
      "available_zone"     = data.aws_availability_zones.available.names[0]

    }
    inside_subnet2 = {
      "inside_subnet_cidr" = var.inside_net_cidr2  #"10.1.102.0/24"
      "available_zone"     = data.aws_availability_zones.available.names[1]
    }
  }
  private_subnets = {
    private_subnet1 = {
      "private_subnet_cidr" = var.private_net_cidr1  #"10.1.201.0/24"
      "available_zone"     = data.aws_availability_zones.available.names[0]

    }
    private_subnet2 = {
      "private_subnet_cidr" = var.private_net_cidr2  #"10.1.202.0/24"
      "available_zone"     = data.aws_availability_zones.available.names[1]
    }
  }
}
resource "aws_vpc" "application_vpc" {
  cidr_block       = var.vpc_cidr  #"10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.perfix}_vpc"
  }
}

#inside subnet for ec2 ecs
resource "aws_subnet" "application_inside_net" {
  for_each          = local.inside_subnets
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = each.value.inside_subnet_cidr
  availability_zone = each.value.available_zone
  tags = {
    Name = "${var.perfix}_${each.key}"
  }
}

#private subnet for rds redis efs 
resource "aws_subnet" "application_private_net" {
  for_each = local.private_subnets
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = each.value.private_subnet_cidr
  availability_zone = each.value.available_zone
  tags = {
    Name = "${var.perfix}_${each.key}"
  }
}


#create internet gateway
resource "aws_internet_gateway" "appcliaton_internet_gateway" {
  vpc_id = aws_vpc.application_vpc.id
  tags = {
    Name = "${var.perfix}_internet_gateway"
  }
}

#route table 和 双向nat关联
resource "aws_route_table" "application_inside_subnet_route_table" {
  vpc_id = aws_vpc.application_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.appcliaton_internet_gateway.id
  }
  tags = {
    Name = "${var.perfix}_inside_subnet_route_table"
  }
}

#route table 和子网关联
resource "aws_route_table_association" "application_inside_subnet_route_table" {
  for_each = aws_subnet.application_inside_net
  subnet_id      = each.value.id
  route_table_id = aws_route_table.application_inside_subnet_route_table.id
}

