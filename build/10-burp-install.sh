#!/usr/bin/bash
set -eoux pipefail

echo "::group:: Installing Burp Suite Professional"
mkdir -p /tmp/burp
curl --output /tmp/burp/burp_pro_install.sh \
    "https://portswigger.net/burp/releases/download?product=pro&version=2026.1.2&type=Linux"
chmod +x /tmp/burp/burp_pro_install.sh
/tmp/burp/burp_pro_install.sh -dir /opt/BurpSuitePro -q
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

echo "::group:: Burp Suite Skel Config"
mkdir -p /etc/skel/Desktop
cp /usr/share/applications/burpsuite.desktop /etc/skel/Desktop/burpsuite.desktop
chmod +x /etc/skel/Desktop/burpsuite.desktop
mkdir -p /etc/skel/.BurpSuite
echo "::endgroup::"

rm -rf /tmp/burp
echo "✓ Burp Suite Professional installed"
