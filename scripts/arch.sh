#!/usr/bin/env bash

# Update the current system
sudo pacman -Syu

packages=(
    gnome-keyring     # GNOME credentials
    seahorse          # GNOME Keyring GUI
    gvfs-smb          # Nautilus SMB support
    man
    tree
    less
    htop
    btop
    nvtop
    neofetch
    loupe            # Light image viewer
    evince           # PDF viewer
    fzf              # Fuzzy finder
    pinta            # Image editor
    zed              # Zed text editor
    nwg-displays     # Hyprland Display manager
    nwg-look         # Hyprland Look manager
    pacseek          # Pacman GUI
    cliphist         # Clipboard history
    blueberry        # Bluetooth Manager
    gnome-calculator
    vlc
    gnome-disk-utility     # Disk manager
    qt6-virtualkeyboard    # Virtual Keyboard for SDDM
    transmission-gtk       # Torrent client
    swaync               # Notifications
    rofi
    rofi-emoji
    ttf-jetbrains-mono-nerd  # JetBrains Mono Nerd Font
    ttf-montserrat          # Montserrat Font
    ttf-fira-sans          # Fira Sans Font
    ttf-font-awesome       # Font Awesome
    xdg-desktop-portal-hyprland  # Screen casting for Hyprland
    wlogout               # Wayland logout menu
    waybar
)


sudo pacman -S "${packages[@]}"

yay -S bibata-cursor-theme-bin # cursor theme

systemctl --user enable --now gnome-keyring-daemon gcr-ssh-agent ssh-agent
ssh-add ~/.ssh/github
