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

# waybar + ML4W
create_symlink "waybar" ~/.config/waybar/themes/tanis ~/dotfiles/waybar/themes/tanis
echo "/tanis;/tanis/white" > ~/.config/ml4w/settings/waybar-theme.sh

# Hyprland + ML4W
# hyprland decorations
create_symlink "hyprland decorations" ~/.config/hypr/conf/decorations/tanis-decorations.conf ~/dotfiles/hypr/decorations.conf
set_config "hyprland decorations" ~/.config/hypr/conf/decoration.conf ~/.config/hypr/conf/decorations/tanis-decorations.conf
# hyprland keybindings
create_symlink "hyprland keybindings" ~/.config/hypr/conf/keybindings/tanis-keybindings.conf ~/dotfiles/hypr/keybindings.conf
set_config "hyprland keybindings" ~/.config/hypr/conf/keybinding.conf ~/.config/hypr/conf/keybindings/tanis-keybindings.conf
# hyprland monitors
create_symlink "hyprland monitors" ~/.config/hypr/conf/monitors/tanis-monitors.conf ~/dotfiles/hypr/monitors.conf
set_config "hyprland monitors" ~/.config/hypr/conf/monitor.conf ~/.config/hypr/conf/monitors/tanis-monitors.conf
# hyprland window rules
create_symlink "hyprland window rules" ~/.config/hypr/conf/windowrules/tanis-window-rules.conf ~/dotfiles/hypr/window-rules.conf
set_config "hyprland window rules" ~/.config/hypr/conf/windowrule.conf ~/.config/hypr/conf/windowrules/tanis-window-rules.conf
# hyprland windows
create_symlink "hyprland windows" ~/.config/hypr/conf/windows/tanis-windows.conf ~/dotfiles/hypr/windows.conf
set_config "hyprland windows" ~/.config/hypr/conf/window.conf ~/.config/hypr/conf/windows/tanis-windows.conf
# hyprland workspaces
create_symlink "hyprland workspaces" ~/.config/hypr/conf/workspaces/tanis-workspaces.conf ~/dotfiles/hypr/workspaces.conf
set_config "hyprland workspaces" ~/.config/hypr/conf/workspace.conf ~/.config/hypr/conf/workspaces/tanis-workspaces.conf
# hyprland custom config
set_config "hyprland custom config" ~/.config/hypr/conf/custom.conf ~/dotfiles/hypr/custom.conf

#########################
# root stuff
#########################

# nanorc
copy_as_root "nanorc" ~/dotfiles/nano/nanorc /root/.config/nano/nanorc

# sddm theme
copy_as_root "earth SSDM theme" ~/dotfiles/sddm/themes/earth /usr/share/sddm/themes/earth
copy_as_root "SSDM config" ~/dotfiles/sddm/sddm.conf /etc/sddm.conf.d/sddm.conf
