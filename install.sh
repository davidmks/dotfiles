#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "linked $dst -> $src"
}

echo "==> Symlinking dotfiles"
link .gitconfig ~/.gitconfig
link .gitignore_global ~/.gitignore_global
link .zshrc ~/.zshrc
link .zprofile ~/.zprofile
link .tmux.conf ~/.tmux.conf
link ghostty/config ~/.config/ghostty/config
link gh/config.yml ~/.config/gh/config.yml
link gh-dash/config.yml ~/.config/gh-dash/config.yml
link sarj/config.toml ~/.config/sarj/config.toml
link tmux-sessionizer/tmux-sessionizer.conf ~/.config/tmux-sessionizer/tmux-sessionizer.conf

if command -v brew &>/dev/null; then
  echo "==> Installing Homebrew packages"
  brew bundle --file="$DOTFILES/Brewfile"
else
  echo "==> Homebrew not found, skipping brew bundle"
fi

echo "==> Done"
