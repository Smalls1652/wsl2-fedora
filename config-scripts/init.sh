#!/bin/bash

echo -e "- Installing packages and updating existing packages -"
dnf install -y man-db
if [ $(cat /etc/dnf/dnf.conf | grep "tsflags=nodocs" --count) = 1 ]; then
    echo -e "- dnf is configured to not install docs, setting it to install man pages -"
    echo -e "\n- /etc/dnf/dnf.conf | Before:"
    cat /etc/dnf/dnf.conf

    echo "[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True" > /etc/dnf/dnf.conf

    echo -e "\n- /etc/dnf/dnf.conf | After:"
    cat /etc/dnf/dnf.conf
    echo -e "\n"

    echo -e "- Reinstalling all existing packages to get man pages -"
    dnf reinstall -y $(sudo dnf list --installed | awk '{print $1}')
    mandb --create
fi

# Update all existing packages installed in the image.
dnf upgrade --refresh -y

# Install packages that will be useful in WSL.
dnf install -y sudo passwd dnf vim wget util-linux readline net-tools openssh openssl zip unzip cracklib-dicts

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
root=/mnt

[boot]
systemd=true" > /etc/wsl.conf

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