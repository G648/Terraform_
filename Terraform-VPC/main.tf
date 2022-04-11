terraform {
  required_providers {
    aws = {
        source ="hashicorp/aws"
        version = "~> 4.9.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile="default"
  region = "us-east-1" 
}

resource "aws_key_pair" "ec2-key" {
    key_name = "ec2-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKJ/0n3/9K0Ennbt7/1acJzwNY01IaaEJGiQqdPTzehofaenuUSiH5H9SEmsuDguj7KSiJEgMLBnJ7DJLJRqkwUFPz1035SKUgqrlJszsTyXtyl9EUdWP2qL6s1E37VLFUNZykK7sUkwFzW5O295rfVZRlph4lVhPaQDCU3oiIT5FQW8aDTDHe+6YTNkuwrPYJRji837sKWgVJCFQBbBT2h375nG9jDJMc4dkNb00kWhMAXQo0gtnNU6nnOSP5UvObpNzIdvqWMeXgP4FnMeQGKATqNR5Mv4KDERaoCwJmcRWRhUZ2CDIq9HTiqSaV9ahvX3g00FSy5ddyuvZF3Vn5"
}

# vpc principal
resource "aws_vpc" "vpc-principal" {
    cidr_block = "192.168.0.0/16"

    tags = {
      "name" = "vpc-principal"
    }
  
}

# subnet secundaria
resource "aws_subnet" "secundary_subnet" {
    vpc_id = aws_vpc.vpc-principal.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        "name" = "private_subnet"
    }
  
}
# subnet principal
resource "aws_subnet" "primary_subnet" {
  vpc_id = aws_vpc.vpc-principal.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "name" = "public_subnet"
  }
}

# instancia ubuntu-docker
resource "aws_instance" "docker-ec2" {
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    key_name = "ec2-key"
    subnet_id = "${aws_subnet.primary_subnet.id}"

    tags = {
      type ="master"
    }
  security_groups = ["${aws_security_group.docker-sg.name}"]
}

resource "aws_security_group" "docker-sg" {
    vpc_id = aws_vpc.vpc-principal.id

    ingress {
      from_port = 0
      to_port =0
      protocol = "-1"
      self = true
    } 
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "regra de entrada para ssh"
    }
    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      to_port = 0
      protocol = "-1"
      
    } 
}