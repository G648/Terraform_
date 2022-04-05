terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
resource "aws_key_pair" "k8s-key"{
    key_name = "k8s-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr7+1zzVPUqmSSpsvUmMJawq1kw5ccx0tID4LjuOhTXms6TmIW98/7/FFJLpeKsIMLFI0i8wwCfxYIN847EXnrDNhg+xTxv26cuv3mfkOcUiKHnmEQnRinxV5a0PmWQ+9AtgUbPdp1L4L20YDGpVstnWhjhUMKwc9NWDKpxO4UqSUbt8Z8GBPqqTpS9kr9h8DX7A9wqbKFSmyE543/IGeqn/PcYqeIxt6xCBf7EC05OTj7dtdv8fFPKY4SEHhQf0EDHieYqBap6p2yrZXi4cbLv4kWiM3Tw/8lcmyLFmL/HasS/DrSSS8GZIBlxYpukKt4fqCJFyvoAMK7Bj5nybFl"
}

resource "aws_instance" "instanciateste01" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name = "k8s-key"
  count = 2
  tags = {
    Name = "primeiro_código_terraform"
    type = "master"
  }
  security_groups = ["${aws_security_group.k8s-sg.name}"]
}

resource "aws_instance" "instancia_teste02"{
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    key_name = "k8s-key"
    tags = {
        Name = "segundo_código_terraform"
        type = "worker"
    }
    security_groups = ["${aws_security_group.k8s-sg.name}"] 
}

resource "aws_security_group" "k8s-sg"{
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self = true
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        cidr_blocks =["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
    }
}
