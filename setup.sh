#/usr/bin/env bash

# zed
rm -f ~/.config/zed/settings.json
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json

# kitty
rm -f ~/dotfiles/.config/kitty/custom.conf
ln -s ~/dotfiles/kitty/custom.conf ~/dotfiles/.config/kitty/custom.conf
