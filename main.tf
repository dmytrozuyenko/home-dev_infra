variable "access_key"{}
variable "secret_key"{}


provider "aws" {
 region     = "us-east-2"
 access_key = var.access_key
 secret_key = var.secret_key
}


resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  
  tags = {
    name = "home"
  }
}

resource "aws_security_group" "main" {
  name        = "home"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# RDS

# ECS
# HOME-APPLICATION
# 


resource "aws_ecs_cluster" "main" {
  name = "home"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# resource "aws_ecs_service" "mongo" {
#   name            = "mongodb"
#   cluster         = aws_ecs_cluster.foo.id
#   task_definition = aws_ecs_task_definition.mongo.arn
#   desired_count   = 3
#   iam_role        = aws_iam_role.foo.arn
#   depends_on      = [aws_iam_role_policy.foo]

#   ordered_placement_strategy {
#     type  = "binpack"
#     field = "cpu"
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }





# locals {
#   prefix = "${var.prefix}-${terraform.workspace}"
#   common_tags = {
#     Environment = terraform.workspace
#     Project     = var.project
#     Owner       = var.contact
#     ManagedBy   = "Terraform"
#   }
# }

# data "aws_region" "current" {}
