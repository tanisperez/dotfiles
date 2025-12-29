#!/usr/bin/env bash

# Update the current system
sudo pacman -Syu

packages=(
    git
    kitty
    power-profiles-daemon # Power profiles
    powerdevil # Power profiles integration in KDE
    man
    tree
    less
    htop
    btop
    nvtop
    s-tui
    duf
    ncdu
    procs
    fastfetch
    loupe            # Light image viewer
    fzf              # Fuzzy finder
    zed              # Zed text editor
    vlc
    vlc-plugins-all
    transmission-qt  # Torrent client
    zsh
    zsh-autosuggestions
    ttf-jetbrains-mono
    kwalletmanager
    keychain
    gocryptfs # KWallet
    fuse
)

sudo pacman -S "${packages[@]}"

# yay
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

yay_packages=(
    pinta       # Image editor
    brave-bin
)
yay -S "${yay_packages[@]}"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Power profiles
sudo systemctl enable power-profiles-daemon.service
