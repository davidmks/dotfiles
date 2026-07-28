# dotfiles

Personal dotfiles for macOS.

## What's included

- **git** — `.gitconfig`, `.gitignore_global`
- **zsh** — `.zshrc`, `.zprofile` (oh-my-zsh)
- **tmux** — `.tmux.conf`
- **ghostty** — `ghostty/config`
- **gh** — `gh/config.yml` (not `hosts.yml`, that's auth state, regenerate with `gh auth login`)
- **gh-dash** — `gh-dash/config.yml`
- **sarj** — `sarj/config.toml`
- **tmux-sessionizer** — `tmux-sessionizer/tmux-sessionizer.conf`
- **Brewfile** — Homebrew packages, casks, and Go tools

Neovim config is separate: [nvim-config](https://github.com/davidmks/nvim-config), cloned into `~/.config/nvim` by `install.sh`.

## Setup

### Brand new Mac

```sh
git clone git@github.com:davidmks/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Installs Xcode Command Line Tools and Homebrew if missing, then runs `install.sh`.

### Already has Homebrew

```sh
git clone git@github.com:davidmks/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Symlinks all configs, clones `nvim-config` into `~/.config/nvim` if missing, runs `brew bundle`. Existing files are backed up to `*.bak`. Safe to re-run.
