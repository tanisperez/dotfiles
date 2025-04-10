#!/usr/bin/env bash

create_symlink_with_backup() {
    local config=$1
    local source=$2
    local target=$3
    local backup_dir="$HOME/.config/backup"

    # If exists and not a symlink
    if [ -e "$source" ] && [ ! -L "$source" ]; then
        if ! mkdir -p "$backup_dir" 2>/dev/null; then
            echo -e "\e[31m[✗] Error creating backup directory\e[0m"
            return 1
        fi

        local backup_name="$(basename "$source")_bak"
        local backup_path="$backup_dir/$backup_name"

        if mv "$source" "$backup_path" 2>/dev/null; then
            if ln -sf "$target" "$source"; then
                echo -e "\e[32m[✓] $config configured successfully (backup in $backup_path)\e[0m"
            else
                echo -e "\e[31m[✗] Error creating symlink for $config\e[0m"
                return 1
            fi
        else
            echo -e "\e[31m[✗] Error backing up $config configuration\e[0m"
            return 1
        fi
    else
        # Remove source if it is a symlink
        if [ -L "$source" ]; then
            rm "$source"
        fi

        if ln -sf "$target" "$source"; then
            echo -e "\e[32m[✓] $config configured successfully\e[0m"
        else
            echo -e "\e[31m[✗] Error creating symlink for $config\e[0m"
            return 1
        fi
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
# create_symlink_with_backup "ssh" ~/.ssh/config ~/dotfiles/ssh/config
# zed
create_symlink_with_backup "zed" ~/.config/zed/settings.json ~/dotfiles/zed/settings.json
# kitty
create_symlink_with_backup "kitty" ~/.config/kitty ~/dotfiles/kitty
# nano
create_symlink_with_backup "nano" ~/.config/nano ~/dotfiles/nano
# oh-my-zsh
create_symlink_with_backup "oh-my-zsh" ~/.zshrc ~/dotfiles/zsh/zshrc
# hyprland
# create_symlink_with_backup "hyprland" ~/.config/hypr ~/dotfiles/hypr
# wlogout
# create_symlink_with_backup "wlogout" ~/.config/wlogout ~/dotfiles/wlogout

#########################
# root stuff
#########################

# nanorc
copy_as_root "nanorc" ~/dotfiles/nano/nanorc /root/.config/nano/nanorc

# sddm theme
# copy_as_root "earth SSDM theme" ~/dotfiles/sddm/themes/earth /usr/share/sddm/themes/earth
# sudo mkdir -p /etc/sddm.conf.d
# copy_as_root "SSDM config" ~/dotfiles/sddm/sddm.conf /etc/sddm.conf.d/sddm.conf
