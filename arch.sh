#!/usr/bin/env bah

sudo pacman -S
    gnome-keyring \ # GNOME credentials
    seahorse \ # GNOME Keyring GUI

systemctl --user enable ssh-agent
ssh-add ~/.ssh/github
