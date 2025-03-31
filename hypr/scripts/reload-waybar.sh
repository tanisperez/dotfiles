#!/bin/env bash

killall -e waybar
waybar -c ~/dotfiles/waybar/themes/tanis/config -s ~/dotfiles/waybar/themes/tanis/style.css &
