#!/bin/bash

# Install prerequisites
sudo yum -y -q update
sudo amazon-linux-extras install -y nginx1

# Configure nginx
sudo cp -f /tmp/host-files/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx && sudo systemctl start nginx

# Configure Datadog

datadog_agent_version=7.33.1-1
wget -nv https://s3.amazonaws.com/yum.datadoghq.com/stable/7/x86_64/datadog-agent-${datadog_agent_version}.x86_64.rpm
sudo yum localinstall -y datadog-agent-${datadog_agent_version}.x86_64.rpm
rm datadog-agent-${datadog_agent_version}.x86_64.rpm
sudo -udd-agent cp -vR datadog-agent /etc/
sudo sed -i "s/# tags:.*/tags: \n  - app: fonetwish/" /etc/datadog-agent/datadog.yaml
sudo sed -i "s/# env: <environment name>/env: dev/" /etc/datadog-agent/datadog.yaml


# Creating logging directory for slackapp
sudo mkdir -p /var/log/slackapp

# Create Slackapp webhook service
sudo python3 -m venv /opt/slackapp/webhook
sudo /opt/slackapp/webhook/bin/pip install --upgrade pip
sudo cp /tmp/host-files/slackapp/app.py /tmp/host-files/slackapp/requirements.txt /opt/slackapp/webhook/
sudo cp /tmp/host-files/slackapp/app.service /usr/lib/systemd/system/slackapp.service
sudo pip3 install --user -r /opt/slackapp/webhook/requirements.txt
sudo systemctl enable slackapp.service && sudo systemctl start slackapp.service