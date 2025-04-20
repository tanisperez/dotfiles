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

- [ ] Add more alias: paccache, remove unused pacman packages and so on.
- [ ] Install oh-my-zsh in the root profile.
