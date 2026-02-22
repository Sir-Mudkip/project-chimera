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

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::endgroup::"
echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
mkdir -p /usr/share/ublue-os/just
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Create ujust wrapper
cat > /usr/bin/ujust << 'EOF'
#!/usr/bin/bash
just --justfile /usr/share/ublue-os/just/60-custom.just "$@"
EOF
chmod +x /usr/bin/ujust

# Copy Welcome Message
mkdir -p /etc/profile.d/
mkdir -p /etc/misc.d/
cp /ctx/custom/system/welcome.sh /etc/profile.d/
cp /ctx/custom/system/ript-welcome.md /etc/misc.d/
chmod 644 /etc/misc.d/ript-welcome.md
chmod 755 /etc/profile.d/welcome.sh

echo "::endgroup::"

echo "::group:: Building Image..."

# User Setup
/ctx/build/01-user-config.sh

# Install Packages
/ctx/build/05-base-packages.sh

# Pentesting Packages
/ctx/build/10-burp-install.sh

# Sys Config
/ctx/build/25-system-config.sh

# Clean Scripts
/ctx/build/50-clean.sh

# Validate Repos
/ctx/build/60-validate-repos.sh

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
