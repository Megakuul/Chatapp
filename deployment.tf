terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}


provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_lauch = true
}

resource "aws_ecs_cluster" "cluster" {
    name = "chatapp-webserver"
}

resource "aws_ecs_task_definition" "task" {
  family = "chatapp-webserver-tasks"
  container_definitions = <<EOF
    [
        {
            "name": "chatapp_webserver01",
            "image": "nginx:latest",
            "cpu": 1,
            "memory": 512,
            "essential": true
        }
    ]
EOF
}

resource "aws_ecs_service" "service" {
    name            = "chatapp-webservice"
    cluster         = aws_ecs_cluster.cluster.id
    task_definition = aws_ecs_task_definition.task.arn
    desired_count = 1
}


