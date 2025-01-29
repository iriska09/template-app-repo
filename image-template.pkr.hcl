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

variable "source_ami" {
  default = "ami-03638f11378d0a14f"  
}

source "amazon-ebs" "ami" {
  region           = "us-east-1"
  source_ami       = var.source_ami
  instance_type    = "t2.micro"
  ssh_username     = "ubuntu"
  ami_name         = var.ami_name

  tags = {
    "Environment" = "Dev"
    "Project"     = "dynamic-python-project"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip",
      "pip3 install -r requirements.txt",
      "python3 app.py"
    ]
  }
}


