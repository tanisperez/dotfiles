#!/usr/bin/env bah

sudo pacman -S
    gnome-keyring \ # GNOME credentials
    seahorse \ # GNOME Keyring GUI
    gvfs-smb \ # Nautilus SMB support
    man \
    less \
    loupe \ # Light image viewer
    blueberry \ # Bluetooth Manager
    gnome-calculator

yay -S smile # emoji picker

systemctl --user enable --now gnome-keyring-daemon gcr-ssh-agent ssh-agent
ssh-add ~/.ssh/github
