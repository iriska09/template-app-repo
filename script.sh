#!/bin/bash
# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y python3-full python3-pip python3-venv 

# Transfer the app.zip file to the target location
pwd
ls -alh
ls -al /home/ubuntu/app 

export PATH=$PATH:/home/ubuntu/.local/bin

cd /home/ubuntu/app

pip3 install -r requirements.txt
python3 app.py

