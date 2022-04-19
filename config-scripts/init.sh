#!/bin/bash

# Update all existing packages installed in the image.
echo -e "- Updating already installed packages -"
dnf upgrade --refresh -y

# Install packages that will be useful in WSL.
echo -e "- Installing packages -"
dnf install -y man-db
dnf install -y sudo passwd dnf vim wget util-linux readline net-tools openssh openssl zip unzip
dnf reinstall -y shadow-utils

# Add the default bash profile settings.
echo -e  "- Adding default Bash profile -"
mv -f /tmp/default-bash-profile/bashrc /etc/bashrc
rm -rf /etc/profile.d/*
mv -f /tmp/default-bash-profile/profile.d/* /etc/profile.d/

echo "# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern \"**\" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar" > /etc/profile.d/wsl-shell.sh

# Configure 'wsl.conf'
echo -e "- Configuring 'wsl.conf' file - "
echo "[automount]
enabled=true
root=/mnt" > /etc/wsl.conf

# Cleanup the temp directory for the default bash profile.
rm -rf /tmp/default-bash-profile

# Set vim as the default text editor, otherwise nano will be the default.
echo -e "- Setting vim as the default text editor -"
dnf install -y vim-default-editor

# Install any extra packages:
#   * bash-completion - For populating tab completion
echo -e "- Installing extra packages -"
dnf install -y bash-completion

# Cleanup unused packages to make the image smaller.
echo -e "- Cleaning up -"
dnf autoremove -y
dnf clean all