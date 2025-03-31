#!/usr/bin/env bash

is_not_symlink() {
    if [ -L "$1" ]; then
        return 1  # not a symlink
    else
        return 0  # it's a symlink
    fi
}

create_symlink() {
    local config=$1
    local source=$2
    local target=$3

    if is_not_symlink "$source"; then
        if ln -sf "$target" "$source"; then
            echo -e "\e[32m[✓] $config configured successfully\e[0m"
        else
            echo -e "\e[31m[✗] Error creating symlink for $config\e[0m"
            return 1
        fi
    else
        echo -e "\e[33m[!] $config symlink is already configured\e[0m"
    fi
}

create_symlink_with_backup() {
    local config=$1
    local source=$2
    local target=$3

    if is_not_symlink "$source"; then
        if mv "$source" "$source.bak" 2>/dev/null; then
            if ln -sf "$target" "$source"; then
                echo -e "\e[32m[✓] $config configured successfully\e[0m"
            else
                echo -e "\e[31m[✗] Error creating symlink for $config\e[0m"
                return 1
            fi
        else
            echo -e "\e[31m[✗] Error backing up $config configuration\e[0m"
            return 1
        fi
    else
        echo -e "\e[33m[!] $config symlink is already configured\e[0m"
    fi
}

set_config() {
    local config=$1
    local source=$2
    local target=$3

    if echo "source = $target" > "$source" 2>/dev/null; then
        echo -e "\e[32m[✓] $config configured successfully\e[0m"
    else
        echo -e "\e[31m[✗] Error configuring $config\e[0m"
        return 1
    fi
}

copy_as_root() {
    local config=$1
    local source=$2
    local target=$3
    
    if sudo rm -Rf "$target" 2>/dev/null && sudo cp -Rf "$source" "$target" 2>/dev/null; then
        echo -e "\e[32m[✓] $config configured successfully\e[0m"
    else
        echo -e "\e[31m[✗] Error configuring $config\e[0m"
        return 1
    fi
}

# ssh
create_symlink_with_backup "ssh" ~/.ssh/config ~/dotfiles/ssh/config
# zed
create_symlink_with_backup "zed" ~/.config/zed/settings.json ~/dotfiles/zed/settings.json
# kitty
create_symlink_with_backup "kitty" ~/.config/kitty/custom.conf ~/dotfiles/kitty/custom.conf
# nano
create_symlink_with_backup "nano" ~/.config/nano/nanorc ~/dotfiles/nano/nanorc
# oh-my-zsh
create_symlink_with_backup "oh-my-zsh" ~/.zshrc ~/dotfiles/zsh/zshrc
# gtk settings
create_symlink_with_backup "gtk settings" ~/.config/gtk-3.0/settings.ini ~/dotfiles/gtk-3.0/settings.ini
# hyprland
create_symlink "hyprland" ~/.config/hypr ~/dotfiles/hypr
# wlogout
create_symlink "wlogout" ~/.config/wlogout ~/dotfiles/wlogout 

#########################
# root stuff
#########################

# nanorc
copy_as_root "nanorc" ~/dotfiles/nano/nanorc /root/.config/nano/nanorc

# sddm theme
copy_as_root "earth SSDM theme" ~/dotfiles/sddm/themes/earth /usr/share/sddm/themes/earth
copy_as_root "SSDM config" ~/dotfiles/sddm/sddm.conf /etc/sddm.conf.d/sddm.conf
