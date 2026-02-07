#!/usr/bin/bash

# Tell build process to exit if there are any errors.
set -oue pipefail

# Install Burp Suite:
mkdir -p /tmp/burp
curl --output /tmp/burp/burp_pro_install.sh "https://portswigger.net/burp/releases/download?product=pro&version=2026.1.2&type=Linux"
chmod +x /tmp/burp/burp_pro_install.sh
/tmp/burp/burp_pro_install.sh -dir /opt/BurpSuitePro -q

# Create Desktop Entry for all users
cat > /usr/share/applications/burpsuite.desktop <<EOF
[Desktop Entry]
Name=Burp Suite Professional
Comment=Web Application Security Testing
Exec=/opt/BurpSuitePro/BurpSuitePro
Icon=/opt/BurpSuitePro/burpicon.png
Terminal=false
Type=Application
Categories=Development;Security;Network;
StartupNotify=true
EOF

# Ensure desktop file is executable
chmod 644 /usr/share/applications/burpsuite.desktop

# Create symlink in /usr/local/bin for CLI access
ln -sf /opt/BurpSuitePro/BurpSuitePro /usr/local/bin/burpsuite

# Set proper permissions on Burp installation
chmod -R 755 /opt/BurpSuitePro

# Create Desktop shortcut for pentest user
mkdir -p /var/home/pentest/Desktop
cp /usr/share/applications/burpsuite.desktop /var/home/pentest/Desktop/burpsuite.desktop
chmod +x /var/home/pentest/Desktop/burpsuite.desktop
chown -R pentest:pentest /var/home/pentest/Desktop

# Ensure pentest user has access to Burp config directory
mkdir -p /var/home/pentest/.BurpSuite
chown -R pentest:pentest /var/home/pentest/.BurpSuite

# Cleanup
rm -rf /tmp/burp

echo "✓ Burp Suite Professional installed to /opt/BurpSuitePro"
echo "✓ Desktop shortcut created for pentest user"
echo "✓ Available via Applications menu and Desktop icon"
echo "✓ CLI accessible via 'burpsuite' command"
