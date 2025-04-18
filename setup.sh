#!/bin/bash

set -e

# Update system
apt update && apt upgrade -y

# Create user and add SSH key
adduser woptop
usermod -aG sudo woptop
mkdir -p /home/woptop/.ssh
echo "your-actual-public-key-here" > /home/woptop/.ssh/authorized_keys
chown -R woptop:woptop /home/woptop/.ssh
chmod 700 /home/woptop/.ssh
chmod 600 /home/woptop/.ssh/authorized_keys


# Set up UFW and Fail2Ban
apt install ufw fail2ban -y
ufw allow OpenSSH
ufw --force enable
systemctl enable fail2ban
systemctl start fail2ban

# Harden SSH config
echo "
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
MaxAuthTries 3
" >> /etc/ssh/sshd_config
systemctl restart ssh

# Lock root
usermod --shell /sbin/nologin root
passwd --lock root

# Create system user for node
adduser --system --home /opt/node --shell /sbin/nologin --group node
mkdir -p /opt/node
chown -R node:node /opt/node

echo "✅ Setup complete. SSH key must be added to /home/woptop/.ssh/authorized_keys before locking yourself out!"
