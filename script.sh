#!/bin/bash
# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y python3-full python3-pip python3-venv 

# Transfer the app.zip file to the target location
mkdir -p /home/ubuntu/app
pwd
ls -alh
# mv 


# # Unzip the app.zip file
# unzip /home/ubuntu/app/app.zip -d /home/ubuntu/app/

# # Navigate to the app directory
# cd /home/ubuntu/app/app

# # Create and activate a virtual environment
# python3 -m venv venv
# source venv/bin/activate

# # Install application dependencies
# pip install --break-system-packages -r requirements.txt

# # Run the Python application
# python app.py
