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

# waybar
ln -s ~/dotfiles/waybar/themes/tanis ~/dotfiles/.config/waybar/themes/tanis
echo "/tanis;/tanis/white" > ~/dotfiles/.config/ml4w/settings
