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
  name       = "chatapp-db-01-subnet"
  subnet_ids = [aws_subnet.chatapp-vpc-subnet01.id, aws_subnet.chatapp-vpc-subnet02.id ]
  tags = {
    Name = "chatapp-db-01-subnet"
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

//Now you have to install the Docker Services on either a ECS instance or a EKS Cluster

//Enter this to get access to EKS Cluster aws eks --region us-east-1 update-kubeconfig --name [Cluster Name]



resource "aws_security_group" "https" {
  name        = "HTTPS"
  description = "HTTPS Port 443 Open"
  vpc_id      = aws_vpc.eks-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


variable "eks-role-arn" {
  type = string
}

resource "aws_eks_cluster" "eks-cluster" {
  name = "EKS-Cluster"
  role_arn = var.eks-role-arn
  vpc_config {
    subnet_ids = [aws_subnet.eks-a-1.id, aws_subnet.eks-b-1.id, aws_subnet.eks-c-1.id, aws_subnet.eks-d-1.id, aws_subnet.eks-f-1.id]
    security_group_ids = [aws_security_group.https.id]
  }
}


resource "aws_eks_node_group" "eks-cluster-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-cluster-node-group"
  subnet_ids = [aws_subnet.eks-a-1.id, aws_subnet.eks-b-1.id, aws_subnet.eks-c-1.id, aws_subnet.eks-d-1.id, aws_subnet.eks-f-1.id]
  node_role_arn = var.eks-role-arn
  scaling_config {
    desired_size = 5
    max_size = 5
    min_size = 5
  }
  disk_size = 20
  instance_types = ["t3.medium"]
  remote_access {
    ec2_ssh_key = "eks-nodes"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name = "kube-proxy"
}

resource "aws_eks_addon" "core_dns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name = "core-dns"
}

resource "aws_eks_addon" "amazon_vpc_cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name = "amazon-vpc-cni"
}


resource "null_resource" "send-ps-command" {
  provisioner "local-exec" {
    command = "aws eks --region us-east-1 update-kubeconfig --name EKS-Cluster"
  }
}