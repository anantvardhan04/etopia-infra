#!/bin/bash

# Install prerequisites
yum -y -q update
amazon-linux-extras install -y nginx1

# Configure nginx
cp -f /tmp/host-files/nginx.conf /etc/nginx/nginx.conf
systemctl enable nginx && sudo systemctl start nginx

# Create Slackapp webhook service
python3 -m venv /opt/slackapp/webhook
/opt/slackapp/webhook/bin/pip install --upgrade pip
cp /tmp/host-files/slackapp/app.py /tmp/host-files/slackapp/requirements.txt /opt/slackapp/webhook/
cp /tmp/host-files/slackapp/app.service /usr/lib/systemd/system/slackapp.service
pip3 install --user -r /opt/slackapp/webhook/requirements.txt
systemctl enable slackapp.service && sudo systemctl start slackapp.service