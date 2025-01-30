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
  vpc_id     = "vpc-0ea36c1047d261932"
  subnet_id  = "subnet-055659ff63cc4bea6" 
  tags = {
    "Environment" = "Dev"
    "Project"     = "dynamic-python-project"
  }
}



build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip",
      "pip3 install -r requirements.txt",
      "python3 app.py"
    ]
  }
}


