#!/usr/bin/env bah

sudo pacman -S
    gnome-keyring \ # GNOME credentials
    seahorse \ # GNOME Keyring GUI
    gvfs-smb \ # Nautilus SMB support
    man \
    tree \
    less \
    loupe \ # Light image viewer
    blueberry \ # Bluetooth Manager
    gnome-calculator \
    qt6-virtualkeyboard \ # Virtual Keyboard for SDDM
    rofi-emoji

yay -S smile \ # emoji picker
    bibata-cursor-theme-bin # cursor theme

systemctl --user enable --now gnome-keyring-daemon gcr-ssh-agent ssh-agent
ssh-add ~/.ssh/github
