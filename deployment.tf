terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

//Get current path
locals {
  execution_path = "${path.module}"
}

provider "aws" {
    region = "us-east-1"
}

//Create chatapp vpc
resource "aws_vpc" "chatapp-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "chatapp-vpc"
    }
}

//Create gateway
resource "aws_internet_gateway" "chatapp-vpc-gateway" {
  vpc_id = aws_vpc.chatapp-vpc.id

  tags = {
    Name = "chatapp-vpc-gateway"
  }
}

//Create route table
resource "aws_route_table" "chatapp-vpc-routetable" {
  vpc_id = aws_vpc.chatapp-vpc.id

  tags = {
    Name = "chatapp-vpc-routetable"
  }
}

//Create Subnet Nr. 1
resource "aws_subnet" "chatapp-vpc-subnet01" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "chatapp-vpc-subnet01"
  }
}
//Route Subnet association
resource "aws_route_table_association" "chatapp-vpc-rt-subnet01" {
  subnet_id = aws_subnet.chatapp-vpc-subnet01.id
  route_table_id = aws_route_table.chatapp-vpc-routetable.id
}

//Create Subnet Nr. 2
resource "aws_subnet" "chatapp-vpc-subnet02" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  

  tags = {
    Name = "chatapp-vpc-subnet02"
  }
}
//Route Subnet association
resource "aws_route_table_association" "chatapp-vpc-rt-subnet02" {
  subnet_id = aws_subnet.chatapp-vpc-subnet02.id
  route_table_id = aws_route_table.chatapp-vpc-routetable.id
}


//Create a route from the default gateway to the internet (next gateway hop)
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.chatapp-vpc-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.chatapp-vpc-gateway.id
}


//Allow the Database to connect
resource "aws_security_group" "chatapp-sec-db-egress" {
  name        = "chatapp-sec-db-egress"
  description = "Allows db connection from security group chatapp-sec-db-ingress"
  vpc_id      = "${aws_vpc.chatapp-vpc.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.chatapp-sec-db-ingress.id}"]
  }  
}

//Allow the clients with this security group to connect to the database with the security group "chatapp-sec-db-egress"
resource "aws_security_group" "chatapp-sec-db-ingress" {
  name        = "chatapp-sec-db-ingress"
  description = "Allows all connections from selected security group"
  vpc_id      = "${aws_vpc.chatapp-vpc.id}"
}

//for debug purposes you can also use a security group who allows traffic from everywhere to the database
/*
resource "aws_security_group" "chatapp-sec-db-egress-debug" {
  name = "chatapp-sec-db-egress-debug"
  description = "Allows connections from everywhere"
  vpc_id = "${aws_vpc.chatapp-vpc.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocoll = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

//Create subnet for database
resource "aws_db_subnet_group" "chatapp-db-01-subnet" {
  name       = "db-group"
  subnet_ids = [aws_subnet.chatapp-vpc-subnet01.id, aws_subnet.chatapp-vpc-subnet02.id ]
  tags = {
    Name = "db-group"
  }
}

//Create database instance
resource "aws_db_instance" "chatapp-db-01" { 
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "chatapp-db-01"
  username             = "root"
  password             = "sml12345"
  publicly_accessible  = true
  backup_retention_period = 2
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.chatapp-sec-db-egress.id]
  db_subnet_group_name    = "${aws_db_subnet_group.chatapp-db-01-subnet.id}"
}

//Create Security Group to open port 80
resource "aws_security_group" "chatapp-api-sec" {
  name = "chatapp-api-sec"
  description = "Exposes port 80 to any IPV4"
  vpc_id      = "${aws_vpc.chatapp-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Create task definition for ECS container
resource "aws_ecs_task_definition" "chatapp-api-taskdefinition" {
  family = "chatapp-api-taskdefinition"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  container_definitions = jsonencode([
    {
      "name": "chatapp-api-service", 
      "image": "public.ecr.aws/docker/library/httpd:latest", 
      "portMappings": [
        {
            "containerPort": 80, 
            "hostPort": 80, 
            "protocol": "tcp"
        }
      ], 
      "essential": true, 
      "entryPoint": [
        "sh",
        "-c"
      ], 
      "command": [
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
      ]
    }
  ])
}

//Create main ECS cluster
resource "aws_ecs_cluster" "chatapp-maincluster" {
  name = "chatapp-maincluster"
}

//Create application Loadbalancer
resource "aws_alb" "chatapp-api-alb" {
  name = "chatapp-api-alb"
  internal = false
  security_groups = [aws_security_group.chatapp-api-sec.id]
  subnets = [aws_subnet.chatapp-vpc-subnet01.id, aws_subnet.chatapp-vpc-subnet02.id]
}

resource "aws_alb_target_group" "chatapp-api-targetgroup" {
  name = "chatapp-api-targetgroup"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.chatapp-vpc.id
}

resource "aws_alb_listener" "chatapp-api-listener" {
  load_balancer_arn = aws_alb.chatapp-api-alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.chatapp-api-targetgroup.arn
    type = "forward"
  }
}

//Create service
resource "aws_ecs_service" "chatapp-api-service" {
  name = "chatapp-api-service"
  task_definition = aws_ecs_task_definition.chatapp-api-taskdefinition.id
  cluster = aws_ecs_cluster.chatapp-maincluster.id
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.chatapp-api-sec.id]
    subnets = [aws_subnet.chatapp-vpc-subnet01.id, aws_subnet.chatapp-vpc-subnet02.id]
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.chatapp-api-targetgroup.id
    container_name = "chatapp-api-service"
    container_port = 80
  }
}