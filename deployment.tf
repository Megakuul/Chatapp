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

resource "aws_vpc" "chatapp-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "chatapp-vpc"
    }
}

resource "aws_subnet" "chatapp-vpc-subnet01" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "chatapp-vpc-subnet01"
  }
}

resource "aws_subnet" "chatapp-vpc-subnet02" {
  vpc_id     = aws_vpc.chatapp-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "chatapp-vpc-subnet02"
  }
}

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


//Frontend//-------------------------------------------------------------------
//Frontend//-------------------------------------------------------------------
############
//Frontend//-------------------------------------------------------------------
//Frontend//-------------------------------------------------------------------

//Create S3 Bucket
resource "aws_s3_bucket" "chatapp-s3-frontend" {
  bucket = "chatapp-s3-frontend"
}

resource "aws_s3_bucket_policy" "chatapp-s3-public-policy" {
  bucket = aws_s3_bucket.chatapp-s3-frontend.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::example-bucket/*"
        }
    ]
}
EOF
}

//Frontend//-------------------------------------------------------------------
//Frontend//-------------------------------------------------------------------
############
//Frontend//-------------------------------------------------------------------
//Frontend//-------------------------------------------------------------------



