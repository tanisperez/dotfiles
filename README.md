# dotfiles
My dotfiles

## Installation

If the folder `~/dotfiles` already exists, type the following commands:

```bash
cd ~/dotfiles
git config --global init.defaultBranch main
git init .
git remote add origin https://github.com/tanisperez/dotfiles
git fetch origin
git checkout -b main origin/main
git reset --soft origin/main
```

Otherwise, just `git clone` the repository inside the `$HOME` directory.


## TODO

- [ ] Copy some configs to root. For example: nanorc.
- [ ] Add more alias: paccache, remove unused pacman packages and so on.
- [ ] Explore tuned for laptop performance profiles.
- [ ] Keep working on the Waybar theme.
- [ ] Keep working on the SDDM theme.
- [ ] Install oh-my-zsh in the root profile.
- [ ] Explore some Screen cast software for Hyprland.
- [ ] Explore a browser for screen sharing in Hyprland.
- [ ] Explore a fast emoji picker.
