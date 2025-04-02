#!/usr/bin/env bash

# Update the current system
sudo pacman -Syu

packages=(
    git
    base-devel
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
    nautilus
    hyprpaper
    hypridle
    hyprlock
    loupe            # Light image viewer
    evince           # PDF viewer
    fzf              # Fuzzy finder
    zed              # Zed text editor
    nwg-displays     # Hyprland Display manager
    nwg-look         # Hyprland Look manager
    cliphist         # Clipboard history
    blueberry        # Bluetooth Manager
    gnome-calculator
    vlc
    gnome-disk-utility     # Disk manager
    qt6-virtualkeyboard    # Virtual Keyboard for SDDM
    transmission-gtk       # Torrent client
    swaync                 # Notifications
    rofi
    rofi-emoji
    ttf-jetbrains-mono-nerd  # JetBrains Mono Nerd Font
    ttf-montserrat          # Montserrat Font
    ttf-fira-sans          # Fira Sans Font
    ttf-font-awesome       # Font Awesome
    papirus-icon-theme
    xdg-desktop-portal-hyprland  # Screen casting for Hyprland
    waybar
    zsh
    zsh-autosuggestions
)

sudo pacman -S "${packages[@]}"

# yay
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si


yay_packages=( 
    pinta       # Image editor
    pacseek     # Pacman GUI
    wlogout     # Wayland logout menu
    bibata-cursor-theme-bin # cursor theme
)
yay -S "${yay_packages[@]}"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

#systemctl --user enable --now gnome-keyring-daemon gcr-ssh-agent ssh-agent
#ssh-add ~/.ssh/github
