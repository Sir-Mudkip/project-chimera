# vim: set ft=make :
#######################
### vm-config.just
#######################

[group('System')]
configure-env:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    # Installing Flatpaks
    echo "Installing Flatpak Files"
    brew bundle --file=/usr/share/ublue-os/homebrew/flatpaks.Brewfile

    # workspace shortcuts
    echo "Configuring Gnome Shortcuts"
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

    # shortcuts for terminal and vscodium
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Ptyxis'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'flatpak run app.devsuite.Ptyxis --new-window'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'vscodium'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Control><Alt>v'"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'flatpak run com.vscodium.codium'"

    # window switcher
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"

    # Add minimise button to apps
    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 

    # Enable and start GNOME Desktop	
    echo "Enabling GNOME Desktop..."
    sudo systemctl unmask gdm.service
    sudo systemctl set-default graphical.target
    sudo systemctl enable gdm.service
    sudo systemctl enable xrdp.service
    sudo systemctl enable xrdp-sesman.service
    sudo systemctl enable tailscaled.service
    echo "Starting GNOME now..."
    sudo systemctl isolate graphical.target
    sudo systemctl start xrdp.service
    sudo systemctl start xrdp-sesman.service
    sudo systemctl start tailscaled.service
    echo "✓ GNOME is now active and set as default"
    echo "✓ RDP available on port 3389"

[group('System')]
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
[group('System')]
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
