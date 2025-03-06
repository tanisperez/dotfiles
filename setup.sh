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
echo "source = ~/.config/hypr/conf/decorations/tanis-decorations.conf" > ~/.config/hypr/conf/decoration.conf
# hyprland keybindings
create_symlink "hyprland keybindings" ~/.config/hypr/conf/keybindings/tanis-keybindings.conf ~/dotfiles/hypr/keybindings.conf
echo "source = ~/.config/hypr/conf/keybindings/tanis-keybindings.conf" > ~/.config/hypr/conf/keybinding.conf
# hyprland monitors
create_symlink "hyprland monitors" ~/.config/hypr/conf/monitors/tanis-monitors.conf ~/dotfiles/hypr/monitors.conf
echo "source = ~/.config/hypr/conf/monitors/tanis-monitors.conf" > ~/.config/hypr/conf/monitor.conf
# hyprland window rules
create_symlink "hyprland window rules" ~/.config/hypr/conf/windowrules/tanis-window-rules.conf ~/dotfiles/hypr/window-rules.conf
echo "source = ~/.config/hypr/conf/windowrules/tanis-window-rules.conf" > ~/.config/hypr/conf/windowrule.conf
# hyprland windows
create_symlink "hyprland windows" ~/.config/hypr/conf/windows/tanis-windows.conf ~/dotfiles/hypr/windows.conf
echo "source = ~/.config/hypr/conf/windows/tanis-windows.conf" > ~/.config/hypr/conf/window.conf
# hyprland workspaces
create_symlink "hyprland workspaces" ~/.config/hypr/conf/workspaces/tanis-workspaces.conf ~/dotfiles/hypr/workspaces.conf
echo "source = ~/.config/hypr/conf/workspaces/tanis-workspaces.conf" > ~/.config/hypr/conf/workspace.conf
# hyprland custom config
echo "source = ~/dotfiles/hypr/custom.conf" > ~/dotfiles/.config/hypr/conf/custom.conf
