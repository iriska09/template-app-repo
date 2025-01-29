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
  source_ami       = "ami-0e2c8caa4b6378d8c" 
  instance_type    = "t2.medium"
  ssh_username     = "ubuntu"
  ami_name         = var.ami_name

tags = {
  "Environment" = "Dev"  # Dynamic value using timestamp()
  "Project"     = "project-10"  # Dynamic value using timestamp()
  
  }
}

build {
  sources = ["source.amazon-ebs.ami"]

  # Shell provisioner for direct commands
  provisioner "shell" {
    script = "./script.sh" # Path to your shell script
  }
}