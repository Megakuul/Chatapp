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
    tags = {
        Name = "chatapp-vpc"
    }
}

//Create Subnet Nr. 1
resource "aws_subnet" "chatapp-vpc-subnet01" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "chatapp-vpc-subnet01"
  }
}

//Create Subnet Nr. 2
resource "aws_subnet" "chatapp-vpc-subnet02" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "chatapp-vpc-subnet02"
  }
}

//Create route table
resource "aws_route_table" "chatapp-vpc-routetable" {
  vpc_id = aws_vpc.chatapp-vpc.id

  tags = {
    Name = "chatapp-vpc-routetable"
  }
}

//Create gateway
resource "aws_internet_gateway" "chatapp-vpc-gateway" {
  vpc_id = aws_vpc.chatapp-vpc.id

  tags = {
    Name = "chatapp-vpc-gateway"
  }
}

//Create the Route to the default gateway (this one we created above)
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.chatapp-vpc-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.chatapp-vpc-gateway.id
}

//Now we have to create two Security groups, one to allow HTTP traffic from the Container to the Loadbalancer,
//and one to allow HTTPS traffic from the WAN to the Loadbalancer.

//This is the security group for the nginx container
resource "aws_security_group" "chatapp-vpc-sec-http-allow-nginx" {
  name   = "chatapp-vpc-sec-http-allow-nginx"
  vpc_id = aws_vpc.chatapp-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//This is the security group for the loadbalancer
resource "aws_security_group" "chatapp-vpc-sec-https-allow-loadbalancer" {
  name   = "chatapp-vpc-sec-http-allow-loadbalancer"
  vpc_id = aws_vpc.chatapp-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //Here we will still allow HTTP, but with a listener rule on the loadbalancer we are going to redirect the HTTP to HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Allow the Database to connect
resource "aws_security_group" "chatapp-sec-db-egress" {
  name        = "chatapp-sec-db-egress"
  description = "Allows db connection from security group chatapp-sec-db-ingress"
  vpc_id      = "${aws_vpc.srv-vpc.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "-1"
    security_groups = ["${aws_security_group.chatapp-sec-db-ingress.id}"]
  }  
}

//Allow the clients with this security group to connect to the database with the security group "chatapp-sec-db-egress"
resource "aws_security_group" "chatapp-sec-db-ingress" {
  name        = "chatapp-sec-db-ingress"
  description = "Allows all connections from selected security group"
  vpc_id      = "${aws_vpc.chatapp-vpc.id}"
}

//Now we want to create a management vm to controll the stuff, the vm is going to be a Windows Server 2022 instance