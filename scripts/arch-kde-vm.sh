#!/usr/bin/env bash

# Update the current system
sudo pacman -Syu

packages=(
    git
    kitty
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
    fuse
    spice-vdagent
)

sudo pacman -S "${packages[@]}"

# yay
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

yay_packages=(
    brave-bin
)
yay -S "${yay_packages[@]}"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# spice vdagentd
sudo systemctl enable --now spice-vdagentd.service
