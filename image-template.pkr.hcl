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
  vpc_id     = "vpc-0f3cde7daa94a7762"
  subnet_id  = "subnet-05f5fc56be24d7746" 
  tags = {
    "Environment" = "Dev"
    "Project"     = "dynamic-python-project"
  }
}



build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y || (sleep 30 && sudo apt-get update -y)",
      "sudo apt-get install -y python3 python3-pip || (sleep 30 && sudo apt-get install -y python3 python3-pip)",
      "pip3 install -r app/requirements.txt || (sleep 30 && pip3 install -r app/requirements.txt)",
      "python3 app/app.py"
    ]
  }
}