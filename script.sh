#!/bin/bash

# Set non-interactive mode for debconf
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# Handle deferred service restarts
echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
sudo sed -i 's/^#\$nrconf{restart} =.*/\$nrconf{restart} = "a";/' /etc/needrestart/needrestart.conf || true

# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y python3-full python3-pip python3-venv zip unzip

# Transfer the app.zip file to the target location
mkdir -p /home/ubuntu/app
cp /var/lib/jenkins/workspace/app.zip /home/ubuntu/app/

# Unzip the app.zip file
unzip /home/ubuntu/app/app.zip -d /home/ubuntu/app/

# Navigate to the app directory
cd /home/ubuntu/app/app

# Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install application dependencies
pip install --break-system-packages -r requirements.txt

# Run the Python application
python app.py
