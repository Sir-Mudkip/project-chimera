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

# Work around for flatpak installs for the time being
cat > /usr/lib/systemd/system/flathub-setup.service << 'EOF'
[Unit]
Description=Setup Flathub remote
ConditionPathExists=!/var/lib/flatpak/repo/flathub.trustedkeys.gpg
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak remote-add --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable flathub-setup.service

# First boot user home directory
echo "Configuring home directory creation on first boot"
cat > /usr/lib/tmpfiles.d/pentest-home.conf << 'EOF'
d /var/home/pentest 0700 pentest pentest -
EOF

cat > /usr/lib/systemd/system/pentest-home-setup.service << 'EOF'
[Unit]
Description=Setup pentest user home directory
ConditionPathExists=!/var/home/pentest/.setup-done
After=local-fs.target systemd-tmpfiles-setup.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/mkhomedir_helper pentest
ExecStartPost=/usr/bin/touch /var/home/pentest/.setup-done
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable pentest-home-setup.service

echo "Setting UK ISO keyboard layout"
echo "KEYMAP=uk" > /etc/vconsole.conf
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-keyboard << 'EOF'
[org/gnome/desktop/input-sources]
sources=[('xkb', 'gb')]
EOF
dconf update

echo "::endgroup::"
