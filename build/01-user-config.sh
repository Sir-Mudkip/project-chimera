#!/usr/bin/bash

set -euox pipefail

echo "Creating Pentesting User"
useradd -m -G wheel -s /bin/bash pentest
if [ -n "${PASSWORD_HASH:-}" ]; then
    usermod -p "${PASSWORD_HASH}" pentest
    echo "Password hash set from build argument"
else
    echo "WARNING: No PENTEST_PASSWORD_HASH provided - user has no password set"
fi

echo "setting up wheel group"
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd
chmod 0440 /etc/sudoers.d/wheel-nopasswd

# Set pentest as the default user for console login
echo "pentest" > /etc/hostname
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -a pentest --noclear %I \$TERM" > /etc/systemd/system/getty@tty1.service.d/autologin.conf
