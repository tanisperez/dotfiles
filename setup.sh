#!/usr/bin/env bash

# ssh
rm -f ~/.ssh/config
ln -s ~/dotfiles/ssh/config ~/.ssh/config

# zed
rm -f ~/.config/zed/settings.json
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json

# kitty
rm -f ~/dotfiles/.config/kitty/custom.conf
ln -s ~/dotfiles/kitty/custom.conf ~/dotfiles/.config/kitty/custom.conf

# waybar + ML4W
rm -f ~/dotfiles/.config/waybar/themes/tanis
ln -s ~/dotfiles/waybar/themes/tanis ~/dotfiles/.config/waybar/themes/tanis
echo "/tanis;/tanis/white" > ~/dotfiles/.config/ml4w/settings/waybar-theme.sh

# hypr + ML4W
rm -f ~/dotfiles/.config/hypr/conf/decorations/tanis-decorations.conf
ln -s ~/dotfiles/hypr/decorations.conf ~/dotfiles/.config/hypr/conf/decorations/tanis-decorations.conf
echo "source = ~/.config/hypr/conf/decorations/tanis-decorations.conf" > ~/dotfiles/.config/hypr/conf/decoration.conf
