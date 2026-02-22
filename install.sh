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
link .tmux.conf ~/.tmux.conf
link ghostty/config ~/.config/ghostty/config
link alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

if command -v brew &>/dev/null; then
  echo "==> Installing Homebrew packages"
  brew bundle --file="$DOTFILES/Brewfile"
else
  echo "==> Homebrew not found, skipping brew bundle"
fi

echo "==> Done"
