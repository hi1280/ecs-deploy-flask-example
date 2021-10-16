resource "aws_vpc" "main" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - VPC"
  }
  tags_all = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - VPC"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - Public Subnet 1"
  }
  tags_all = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - Public Subnet 1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - Public Subnet 2"
  }
  tags_all = {
    Description = "Created for ECS cluster ecspresso-demo"
    Name        = "ECS ecspresso-demo - Public Subnet 2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "allow_http" {
  name   = "allow_http"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}