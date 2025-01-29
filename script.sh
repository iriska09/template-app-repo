#!/bin/bash

# Set non-interactive mode for debconf
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Pre-configure Postfix
echo "postfix postfix/mailname string example.com" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type select Internet Site" | sudo debconf-set-selections
echo 'this is test'

# Install Postfix non-interactively
sudo apt-get install -y postfix

# Update and upgrade system
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y

# Install necessary packages
sudo apt-get install -y lynis ansible libpam-tmpdir acct sysstat fail2ban rkhunter debsums apt-show-versions apt-listchanges

# Pre-configure iptables-persistent
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections
sudo apt-get install -y iptables-persistent

# Install Ansible role
sudo ansible-galaxy collection install devsec.hardening --force

# Create inventory.yml
cat <<EOF > /home/ubuntu/inventory.yml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_user: ubuntu
EOF

# Create hardening playbook
cat <<EOF > /home/ubuntu/hardening_playbook.yml
---
- name: Hardening Playbook
  hosts: all
  become: yes
  roles:
    - devsec.hardening.os_hardening
    - devsec.hardening.ssh_hardening
EOF

# Run the Ansible playbook
sudo ansible-playbook -i /home/ubuntu/inventory.yml /home/ubuntu/hardening_playbook.yml

# Allow all traffic on the loopback interface
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH access (port 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Drop all other incoming traffic
sudo iptables -A INPUT -j DROP

# Make iptables rules persistent
sudo netfilter-persistent save

# Security hardening configurations
echo "blacklist usb_storage" | sudo tee /etc/modprobe.d/blacklist-usb-storage.conf

sudo sed -i 's/^#\?PrintLastLog no/PrintLastLog yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config

# Add warning banners
echo "Unauthorized access to this system is prohibited and will be prosecuted to the full extent of the law.
All activities are monitored and logged." | sudo tee /etc/issue /etc/issue.net

# Start and enable services
sudo systemctl start acct && sudo systemctl enable acct
sudo systemctl enable sysstat && sudo systemctl start sysstat
sudo systemctl start fail2ban && sudo systemctl enable fail2ban

# Configure Fail2Ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban

# Purge old/removed packages
echo "Purging old packages..."
sudo apt-get autoremove --purge -y

# Ensure Postfix is properly configured
sudo postconf -e 'smtpd_banner=$myhostname ESMTP'
sudo postconf -e 'disable_vrfy_command=yes'
sudo systemctl restart postfix

# Enable sysstat
sudo apt-get install sysstat -y
sudo sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
sudo systemctl enable sysstat
sudo systemctl start sysstat

# Run Lynis audit
sudo lynis audit system
