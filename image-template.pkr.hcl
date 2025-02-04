packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_name" {
  default = "hardened-image-{{timestamp}}"
}

source "amazon-ebs" "ami" {
  region           = "us-east-1"
  source_ami       = "ami-03638f11378d0a14f"
  instance_type    = "t2.medium"
  ssh_username     = "ubuntu"
  ami_name         = var.ami_name
  vpc_id           = "vpc-008b4376ae8b323a3"
  subnet_id        = "subnet-0132864350f0d8ac7"
  tags = {
    "Environment" = "Dev"
    "Project"     = "dynamic-python-project"
  }
}


build {
  sources = ["source.amazon-ebs.ami"]


  # Shell provisioner for direct commands
  provisioner "file" {
    source = "app" // location in Jenkins Server
    destination = "/home/ubuntu" // location in remote ubuntu server for AMI creaion
  }
  provisioner "shell" {
    script = "./script.sh" # This shell script is to create pre-requisites 
  }
}

