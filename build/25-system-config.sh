#!/usr/bin/bash
set -eoux pipefail

mask_service() {
    systemctl disable "$1" 2>/dev/null || true
    systemctl mask "$1" 2>/dev/null || true
}

echo "::group:: System Configuration"

echo "Setting headless boot as default"
systemctl set-default multi-user.target

echo "Enabling remote access services"
systemctl enable sshd.service
systemctl enable tailscaled.service

echo "Enabling podman auto-update"
systemctl --global enable  podman-auto-update.timer

echo "Disabling GDM to prevent GNOME loading on boot"
mask_service gdm.service

echo "Disabling print services"
mask_service cups.socket
mask_service cups.service
mask_service cups-browsed.service

echo "Disabling avahi-daemon"
mask_service avahi-daemon.socket
mask_service avahi-daemon.service

echo "Disabling modem manager"
mask_service ModemManager.service

echo "Disabling sssd daemons"
mask_service sssd.service
mask_service sssd-kcm.service
mask_service sssd-kcm.socket

echo "Disabling location service"
mask_service geoclue.service

echo "::endgroup::"
