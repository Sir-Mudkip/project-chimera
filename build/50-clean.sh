#!/usr/bin/bash
set -eoux pipefail
echo "::group:: ===$(basename "$0")==="

# Disable rpm-ostree automatic updates timer if present
systemctl disable rpm-ostreed-automatic.timer 2>/dev/null || true

# Hide desktop files if present
for file in fish htop nvtop; do
    if [[ -f "/usr/share/applications/$file.desktop" ]]; then
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' \
            /usr/share/applications/"$file".desktop
    fi
done

# Disable repos that were enabled during build
for repo in tailscale epel epel-cisco-openh264; do
    if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
    fi
done

# Disable all CentOS repos
for i in /etc/yum.repos.d/centos*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

# Disable any COPR repos
for i in /etc/yum.repos.d/_copr:*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

dnf clean all

# Cleanup var and tmp
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 -exec rm -fr {} \;
rm -rf /tmp && mkdir -p /tmp
rm -rf /boot && mkdir -p /boot

echo "::endgroup::"
