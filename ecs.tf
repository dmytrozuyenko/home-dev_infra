
resource "aws_security_group" "ecs_service" {
  name        = "home-ecs-service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private.cidr_block,
    ]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }
}


resource "aws_ecs_task_definition" "home-application" {
  family                   = "home-application"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = <<DEFINITION
[
  {
    "image": "209998915568.dkr.ecr.us-east-2.amazonaws.com/home-application:latest",
    "cpu": 256,
    "memory": 512,
    "name": "home-application",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}


resource "aws_security_group" "home-application_task" {
  name        = "home-application-task-security-group"
  vpc_id      = aws_vpc.home.id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_cluster" "home" {
  name = "home"
}


resource "aws_ecs_service" "home-application" {
  name            = "home-application-service"
  cluster         = aws_ecs_cluster.home.id
  task_definition = aws_ecs_task_definition.home-application.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.home-application_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.home-application.id
    container_name   = "home-application"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.home-application]
}


# Data-migration

# resource "aws_ecs_task_definition" "data-migration" {
#   family                   = "data-migration"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512

#   container_definitions = <<DEFINITION
# [
#   {
#     "image": "209998915568.dkr.ecr.us-east-2.amazonaws.com/data-migration:latest",
#     "cpu": 256,
#     "memory": 256,
#     "name": "data-migration",
#     "networkMode": "awsvpc",
#     "environment": [
#         {"name": "DATASOURCE_URL", "value": "jdbc:postgresql://postgres:5432/postgres?user=postgres&password=p0$tgr3$"}
#     ],
#     "portMappings": [
#       {
#         "containerPort": 5001,
#         "hostPort": 5001
#       }
#     ]
#   }
# ]
# DEFINITION
# }


# resource "aws_ecs_service" "data-migration" {
#   name            = "data-migration-service"
#   cluster         = aws_ecs_cluster.home.id
#   task_definition = aws_ecs_task_definition.data-migration.arn
#   desired_count   = var.app_count
#   launch_type     = "FARGATE"

#   network_configuration {
#     security_groups = [aws_security_group.data-migration_task.id]
#     subnets         = aws_subnet.private.*.id
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.data-migration.id
#     container_name   = "data-migration"
#     container_port   = 5001
#   }

#   depends_on = [aws_lb_listener.data-migration]
# }


# resource "aws_security_group" "data-migration_task" {
#   name        = "data-migration-task-security-group"
#   vpc_id      = aws_vpc.home.id

#   ingress {
#     protocol        = "tcp"
#     from_port       = 5001
#     to_port         = 5001
#     security_groups = [aws_security_group.lb.id]
#   }

#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
