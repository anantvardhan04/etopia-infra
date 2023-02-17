#!/bin/bash

# Install prerequisites
sudo yum -y -q update
sudo amazon-linux-extras install -y nginx1

# Configure nginx
sudo cp -f /tmp/host-files/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx && sudo systemctl start nginx

# Create Slackapp webhook service
sudo python3 -m venv /opt/slackapp/webhook
sudo /opt/slackapp/webhook/bin/pip install --upgrade pip
sudo cp /tmp/host-files/slackapp/app.py /tmp/host-files/slackapp/requirements.txt /opt/slackapp/webhook/
sudo cp /tmp/host-files/slackapp/app.service /usr/lib/systemd/system/slackapp.service
pip3 install --user -r /opt/slackapp/webhook/requirements.txt
sudo systemctl enable slackapp.service && sudo systemctl start slackapp.service