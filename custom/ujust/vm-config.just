# vim: set ft=make :
#######################
### vm-config.just
#######################

[group('System')]
install-clipboard-indicator:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git "$HOME"/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com
    dconf write /org/gnome/shell/extensions/clipboard-indicator/toggle-menu "['<Super>v']"
    echo "installed - you need to log out and back in for the extention to be registered"
    echo "you can then enable with gnome-extensions enable clipboard-indicator@tudmotu.com"

[group('System')]
# Enable and start GNOME Desktop
enable-gui:
    #!/usr/bin/env bash
    echo "Enabling GNOME Desktop..."
    sudo systemctl set-default graphical.target
    sudo systemctl enable gdm.service
    sudo systemctl enable xrdp.service
    sudo systemctl enable xrdp-sesman.service
    sudo systemctl enable sshd.service
    echo "Starting GNOME now..."
    sudo systemctl isolate graphical.target
    sudo systemctl start xrdp.service
    sudo systemctl start xrdp-sesman.service
    sudo systemctl start sshd.service
    echo "✓ GNOME is now active and set as default"
    echo "✓ RDP available on port 3389"
    echo "✓ SSH available on port 22"

# Disable GNOME and return to headless
disable-gui:
    #!/usr/bin/env bash
    echo "Disabling GNOME Desktop..."
    sudo systemctl set-default multi-user.target
    sudo systemctl disable gdm.service
    sudo systemctl disable xrdp.service
    sudo systemctl disable xrdp-sesman.service
    echo "Switching to headless mode..."
    sudo systemctl isolate multi-user.target
    echo "✓ System now headless and will boot headless"

# Check GUI status
gui-status:
    #!/usr/bin/env bash
    echo "=== System Target ==="
    systemctl get-default
    echo ""
    echo "=== GDM Status ==="
    systemctl status gdm.service --no-pager || echo "Not running"
    echo ""
    echo "=== xrdp Status ==="
    systemctl status xrdp.service --no-pager || echo "Not running"
 

[group('System')]
configure-gnome:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    # workspace shortcuts
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Super><Shift>1']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-2 "['<Super><Shift>2']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-3 "['<Super><Shift>3']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-4 "['<Super><Shift>4']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-5 "['<Super><Shift>5']"
    dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-6 "['<Super><Shift>6']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>1']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Super>2']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Super>3']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Super>4']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-5 "['<Super>5']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-6 "['<Super>6']"

    # dark mode slate
    dconf write /org/gnome/desktop/interface/accent-color "'slate'"
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

    # fixed number of workspaces at 6
    dconf write /org/gnome/mutter/dynamic-workspaces false
    dconf write /org/gnome/desktop/wm/preferences/num-workspaces 6

    # disable application switching shortcuts
    dconf write /org/gnome/shell/keybindings/switch-to-application-1 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-2 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-3 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-4 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-5 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-6 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-7 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-8 "['']"
    dconf write /org/gnome/shell/keybindings/switch-to-application-9 "['']"

    # auto screen lock disable
    dconf write /org/gnome/desktop/screensaver/lock-enabled false

    # shortcuts for ptyxis and keepass
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Ptyxis'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'/usr/bin/ptyxis --new-window'"

    # window switcher
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"

    # Add minimise button to apps
    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
