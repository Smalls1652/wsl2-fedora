#!/bin/bash

# Configure 'wsl.conf'
echo -e "- Configuring 'wsl.conf' file - "
echo "[automount]
enabled=true
root=/mnt

[boot]
systemd=true" > /etc/wsl.conf