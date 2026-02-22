# dotfiles

Personal dotfiles for macOS.

## What's included

- **git** — `.gitconfig`, `.gitignore_global`
- **zsh** — `.zshrc` (oh-my-zsh)
- **tmux** — `.tmux.conf`
- **ghostty** — `ghostty/config`
- **alacritty** — `alacritty/alacritty.toml`
- **Brewfile** — Homebrew packages, casks, and Go tools

## Setup

```sh
git clone git@github.com:davidmks/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will symlink all configs and run `brew bundle` if Homebrew is available. Existing files are backed up to `*.bak` before overwriting.
