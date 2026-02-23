#!/usr/bin/bash

set -euox pipefail

echo "Creating Pentesting User"
useradd -m -d /var/home/pentest -G wheel -s /bin/bash pentest
if [ -n "${PASSWORD_HASH:-}" ]; then
    usermod -p "${PASSWORD_HASH}" pentest
    echo "Password hash set from build argument"
else
    echo "WARNING: No PASSWORD_HASH provided - user has no password set"
fi

echo "setting up wheel group"
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd
chmod 0440 /etc/sudoers.d/wheel-nopasswd

echo "User configuration complete"