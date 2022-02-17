variable "access_key"{}
variable "secret_key"{}
variable "db_password"{}


provider "aws" {
 region     = "us-east-2"
 access_key = var.access_key
 secret_key = var.secret_key
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "home" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.home.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.home.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.home.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.home.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.home.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.home.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.home.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "db" {
  name        = "db-security-group"
  vpc_id      = aws_vpc.home.id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb" {
  name        = "home-alb-security-group"
  vpc_id      = aws_vpc.home.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "home" {
  name            = "home-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "home-application" {
  name        = "home-application-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.home.id
  target_type = "ip"
}

resource "aws_lb_listener" "home-application" {
  load_balancer_arn = aws_lb.home.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.home-application.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "data-migration" {
  name        = "data-migration-target-group"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.home.id
  target_type = "ip"
}

resource "aws_lb_listener" "data-migration" {
  load_balancer_arn = aws_lb.home.id
  port              = "5001"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.data-migration.id
    type             = "forward"
  }
}
