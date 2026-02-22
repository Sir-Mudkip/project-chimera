#!/usr/bin/bash

set -euox pipefail

echo "Creating Pentesting User"
useradd -M -d /var/home/pentest -G wheel -s /bin/bash pentest
if [ -n "${PASSWORD_HASH:-}" ]; then
    usermod -p "${PASSWORD_HASH}" pentest
    echo "Password hash set from build argument"
else
    echo "WARNING: No PASSWORD_HASH provided - user has no password set"
fi

echo "setting up wheel group"
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd
chmod 0440 /etc/sudoers.d/wheel-nopasswd

echo "Setting hostame"
echo "ript" > /etc/hostname

# Set pentest as the default user for console login
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a pentest --noclear %I $TERM
EOF

echo "User configuration complete"
