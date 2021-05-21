terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "BayHorseInn" {
  ami                         = var.ami_value
  instance_type               = var.instance_type
  security_groups             = ["access-controls"]
  associate_public_ip_address = true
  key_name                    = "ssh-key"

  vpc_security_group_ids = [
    aws_security_group.access-controls.id
  ]

  tags = {
    AmiValue     = var.ami_value
    InstanceType = var.instance_type
  }

  connection {
    type  = "ssh"
    host  = aws_instance.BayHorseInn.public_ip
    user  = var.ssh_user
    port  = var.ssh_port
    agent = true
  }

  provisioner "file" {
    source      = "change_ssh_port.sh"
    destination = "/tmp/change_ssh_port.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -i",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt-get install nginx -y"
    ]
  }
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.BayHorseInn.public_ip
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqr1aEWMbI+xONdv/ezM7c4TK3BUWq+2E8OpTVbkeu2l6hOx+5WgilJezwHOtduJhrfHAktHbPVgo2KCe659w7/mXjZWY90qOZnzP+EXa75f4jAG0nNJ+co4482FfAcG4R/QpVeVMcIeXE3Cy2qS0gKpK70malmTXAKowpcu/uy/4uX8gezKR++aTBWPUeNE9mtDDuw+u2Mk7wRfaqVSPha9dmU6dSLL0pJiNHvnSqL676GxeIHivQSVV9s1hJ90p9z6vazDHT90wiFD2vkgo0XKZR77pZRtkeOtBs3VLggj2cKaujmk3/1ERlIcfxvw9ghHNKUDTfaak/3iNFj2/D7O2HcqygTqpfn9XaMZJ7cufv6xD5fgHuOFHeaGhoS8Akiikws2h88ijIZ1lj58J7r7MnArbNnno8nr6XfozVaQ2l2fXwjV23e8ukNEYY9eSqOTIquSCTZZyM0HaLivrU9l7V86Ef+skohf3sZysJX65cy4fk6HJmq9YQHMO8Oh0= chris@chris.local"
}

resource "aws_security_group" "access-controls" {
  name        = "access-controls"
  description = "Access Controls for SSH and Netdata"

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    description = "SSH Port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    description = "HTTP Port"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    description = "HTTPS Port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    description = "HTTP Port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    description = "HTTPS Port"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
