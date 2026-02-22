#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Configure Repos"
curl -o /etc/yum.repos.d/tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
# Example: dnf5 install -y tmux

# Base packages from Fedora repos - common to all versions
# https://github.com/ublue-os/main/blob/main/packages.json
FEDORA_PACKAGES=(
    fastfetch
    gcc
    gocryptfs
    git
    just
    make
    neovim
    python3-pip
    ripgrep
    stress-ng
    wireguard-tools
    podman-compose
    gum
    tailscale
    tmux
    tcpdump
    cockpit
    cockpit-podman
    cockpit-selinux
    cockpit-machines
    xrdp
)

# Install all Fedora packages (bulk - safe from COPR injection)
echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf -y install "${FEDORA_PACKAGES[@]}"

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

# Packages to exclude - common to all versions
EXCLUDED_PACKAGES=(
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-gnome
    firefox
    firefox-langpacks
    gnome-extensions-app
    gnome-software-rpm-ostree
    podman-docker
)

echo "::endgroup::"

# Gnome install
echo "::group:: Installing gnome so it's 'just there'"
dnf -y install \
    gnome-shell \
    gdm \
    gnome-tweaks \
    gnome-control-center \
    nautilus \
    NetworkManager-wifi \
    NetworkManager-openvpn-gnome

# Flatpak
echo "::group:: Flatpak Config"
dnf install -y flatpak
flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
echo "::endgroup::"
