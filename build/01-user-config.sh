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

echo "Configuring home directory creation on first boot"
cat > /usr/lib/tmpfiles.d/pentest-home.conf << 'EOF'
d /var/home/pentest 0700 pentest pentest -
EOF

cat > /usr/lib/systemd/system/pentest-home-setup.service << 'EOF'
[Unit]
Description=Setup pentest user home directory
ConditionPathExists=!/var/home/pentest/.setup-done
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/mkhomedir_helper pentest
ExecStartPost=/usr/bin/touch /var/home/pentest/.setup-done
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable pentest-home-setup.service

echo "User configuration complete"
