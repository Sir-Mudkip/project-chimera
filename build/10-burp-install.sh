#!/usr/bin/bash
set -eoux pipefail

echo "::group:: Installing Burp Suite Professional"
mkdir -p /tmp/burp
curl --output /tmp/burp/burp_pro_install.sh \
    "https://portswigger.net/burp/releases/download?product=pro&version=2026.1.2&type=Linux"
chmod +x /tmp/burp/burp_pro_install.sh
echo "o" | /tmp/burp/burp_pro_install.sh -dir /opt/BurpSuitePro
chmod -R 755 /opt/BurpSuitePro
echo "::endgroup::"

echo "::group:: Burp Suite Desktop Integration"
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
chmod 644 /usr/share/applications/burpsuite.desktop

ln -sf /opt/BurpSuitePro/BurpSuitePro /usr/bin/burpsuite
echo "::endgroup::"

echo "::group:: Burp Suite User Config"
mkdir -p /var/home/pentest/Desktop
cp /usr/share/applications/burpsuite.desktop /var/home/pentest/Desktop/burpsuite.desktop
chmod +x /var/home/pentest/Desktop/burpsuite.desktop
chown -R pentest:pentest /var/home/pentest/Desktop
mkdir -p /var/home/pentest/.BurpSuite
chown -R pentest:pentest /var/home/pentest/.BurpSuite
echo "::endgroup::"

rm -rf /tmp/burp
echo "✓ Burp Suite Professional installed"
