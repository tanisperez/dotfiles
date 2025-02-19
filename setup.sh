#!/usr/bin/env bash

# ssh
echo -e "\e[1;32mSetting up ssh...\e[0m"
rm -f ~/.ssh/config
ln -s ~/dotfiles/ssh/config ~/.ssh/config

# zed
echo -e "\e[1;32mSetting up Zed...\e[0m"
rm -f ~/.config/zed/settings.json
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json

# kitty
echo -e "\e[1;32mSetting up Kitty...\e[0m"
rm -f ~/dotfiles/.config/kitty/custom.conf
ln -s ~/dotfiles/kitty/custom.conf ~/dotfiles/.config/kitty/custom.conf

# nano
echo -e "\e[1;32mSetting up nano...\e[0m"
rm -f ~/.config/nano/nanorc
ln -s ~/dotfiles/nano/nanorc ~/.config/nano/nanorc

# oh-my-zsh
echo -e "\e[1;32mSetting up oh-my-zsh...\e[0m"
rm -f ~/.zshrc
ln -s ~/dotfiles/zsh/zshrc ~/.zshrc

# waybar + ML4W
echo -e "\e[1;32mSetting up Waybar theme...\e[0m"
rm -f ~/dotfiles/.config/waybar/themes/tanis
ln -s ~/dotfiles/waybar/themes/tanis ~/dotfiles/.config/waybar/themes/tanis
echo "/tanis;/tanis/white" > ~/dotfiles/.config/ml4w/settings/waybar-theme.sh

# Hyprland + ML4W
echo -e "\e[1;32mSetting up Hyprland decorations...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/decorations/tanis-decorations.conf
ln -s ~/dotfiles/hypr/decorations.conf ~/dotfiles/.config/hypr/conf/decorations/tanis-decorations.conf
echo "source = ~/.config/hypr/conf/decorations/tanis-decorations.conf" > ~/dotfiles/.config/hypr/conf/decoration.conf

echo -e "\e[1;32mSetting up Hyprland keybindings...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/keybindings/tanis-keybindings.conf
ln -s ~/dotfiles/hypr/keybindings.conf ~/dotfiles/.config/hypr/conf/keybindings/tanis-keybindings.conf
echo "source = ~/.config/hypr/conf/keybindings/tanis-keybindings.conf" > ~/dotfiles/.config/hypr/conf/keybinding.conf

echo -e "\e[1;32mSetting up Hyprland monitors...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/monitors/tanis-monitors.conf
ln -s ~/dotfiles/hypr/monitors.conf ~/dotfiles/.config/hypr/conf/monitors/tanis-monitors.conf
echo "source = ~/.config/hypr/conf/monitors/tanis-monitors.conf" > ~/dotfiles/.config/hypr/conf/monitor.conf

echo -e "\e[1;32mSetting up Hyprland window rules...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/windowrules/tanis-window-rules.conf
ln -s ~/dotfiles/hypr/window-rules.conf ~/dotfiles/.config/hypr/conf/windowrules/tanis-window-rules.conf
echo "source = ~/.config/hypr/conf/windowrules/tanis-window-rules.conf" > ~/dotfiles/.config/hypr/conf/windowrule.conf

echo -e "\e[1;32mSetting up Hyprland windows...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/windows/tanis-windows.conf
ln -s ~/dotfiles/hypr/windows.conf ~/dotfiles/.config/hypr/conf/windows/tanis-windows.conf
echo "source = ~/.config/hypr/conf/windows/tanis-windows.conf" > ~/dotfiles/.config/hypr/conf/window.conf

echo -e "\e[1;32mSetting up Hyprland workspaces...\e[0m"
rm -f ~/dotfiles/.config/hypr/conf/workspaces/tanis-workspaces.conf
ln -s ~/dotfiles/hypr/workspaces.conf ~/dotfiles/.config/hypr/conf/workspaces/tanis-workspaces.conf
echo "source = ~/.config/hypr/conf/workspaces/tanis-workspaces.conf" > ~/dotfiles/.config/hypr/conf/workspace.conf

echo -e "\e[1;32mSetting up Hyprland custom config...\e[0m"
echo "source = ~/dotfiles/hypr/custom.conf" > ~/dotfiles/.config/hypr/conf/custom.conf
