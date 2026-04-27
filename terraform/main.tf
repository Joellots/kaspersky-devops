
# VPC and Networking
resource "aws_vpc" "microservice" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "microservice-vpc"
  }
}

resource "aws_internet_gateway" "microservice" {
  vpc_id = aws_vpc.microservice.id

  tags = {
    Name = "microservice-igw"
  }
}

resource "aws_subnet" "microservice" {
  vpc_id                  = aws_vpc.microservice.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "microservice-subnet"
  }
}

resource "aws_route_table" "microservice" {
  vpc_id = aws_vpc.microservice.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.microservice.id
  }

  tags = {
    Name = "microservice-rt"
  }
}

resource "aws_route_table_association" "microservice" {
  subnet_id      = aws_subnet.microservice.id
  route_table_id = aws_route_table.microservice.id
}

# Security Group
resource "aws_security_group" "microservice" {
  name        = "microservice"
  description = "Allow SSH and microservice port"


  ingress{
    description = "SSH"
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description = "Microservice"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
}

  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  tags = {
    Name = "Microservice"
  }
}


# Microservice Server
resource "aws_instance" "microservice"{
    ami = var.ami
    instance_type = var.instance_type
    availability_zone = var.zone
    key_name = "vockey"
    vpc_security_group_ids = [aws_security_group.microservice.id]
    associate_public_ip_address = true

    root_block_device {
        volume_size = 25  
        volume_type = "gp3" 
        encrypted   = true
    }


   tags = {
        Name = "microservice-server"
    } 
}

