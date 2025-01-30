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
  source_ami       = "ami-04b4f1a9cf54c11d0"
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

  # Use absolute paths for file provisioners
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/test/app/requirements.txt"
    destination = "/home/ubuntu/requirements.txt"
  }

  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/test/app/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip python3-venv",
      "python3 -m venv /home/ubuntu/venv",
      ". /home/ubuntu/venv/bin/activate",
      "pip install -r /home/ubuntu/requirements.txt",
      "python /home/ubuntu/app.py"
    ]
  }
}