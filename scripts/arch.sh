#!/usr/bin/env bah

# Update the current system
sudo pacman -Syu

sudo pacman -S
    gnome-keyring \ # GNOME credentials
    seahorse \ # GNOME Keyring GUI
    gvfs-smb \ # Nautilus SMB support
    man \
    tree \
    less \
    htop \
    btop \
    nvtop \
    neofetch \
    loupe \ # Light image viewer
    evince \ # PDF viewer
    fzf \ # Fuzzy finder
    pinta \ # Image editor  
    zed \ # Zed text editor
    nwg-displays \ # Hyprland Display manager
    nwg-look \ # Hyprland Look manager
    pacseek \ # Pacman GUI
    cliphist \ # Clipboard history
    blueberry \ # Bluetooth Manager
    gnome-calculator \
    vlc \
    gnome-disk-utility \ # Disk manager
    qt6-virtualkeyboard \ # Virtual Keyboard for SDDM
    transmission-gtk \ # Torrent client
    rofi \
    rofi-emoji \
    ttf-jetbrains-mono-nerd \ # JetBrains Mono Nerd Font
    wlogout # Wayland logout menu

yay -S 
    # smile \ # emoji picker
    bibata-cursor-theme-bin # cursor theme

systemctl --user enable --now gnome-keyring-daemon gcr-ssh-agent ssh-agent
ssh-add ~/.ssh/github
