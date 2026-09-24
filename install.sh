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
link sarj/config.toml ~/.config/sarj/config.toml
link tmux-sessionizer/tmux-sessionizer.conf ~/.config/tmux-sessionizer/tmux-sessionizer.conf
link claude/CLAUDE.md ~/.claude/CLAUDE.md
link claude/settings.json ~/.claude/settings.json
link claude/skills ~/.claude/skills
link claude/hooks ~/.claude/hooks

echo "==> Neovim config"
NVIM_CONFIG=~/.config/nvim
if [ -d "$NVIM_CONFIG" ]; then
  echo "$NVIM_CONFIG already exists, leaving it alone"
else
  git clone git@github.com:davidmks/nvim-config.git "$NVIM_CONFIG"
fi

if command -v brew &>/dev/null; then
  echo "==> Installing Homebrew packages"
  brew trust davidmks/tap 2>/dev/null || true
  brew bundle --file="$DOTFILES/Brewfile"

  # macOS only grants notification permission to apps in ~/Applications, not in the Homebrew cellar.
  notifier_source="$(brew --prefix terminal-notifier)/terminal-notifier.app"
  notifier_app=~/Applications/terminal-notifier.app
  if ! diff -q "$notifier_source/Contents/Info.plist" "$notifier_app/Contents/Info.plist" &>/dev/null; then
    echo "==> Copying terminal-notifier.app to ~/Applications"
    mkdir -p ~/Applications
    rm -rf "$notifier_app"
    cp -R "$notifier_source" ~/Applications/
    echo "Allow its notifications once: open -a $notifier_app --args -message test"
  fi
else
  echo "==> Homebrew not found, skipping brew bundle"
fi

echo "==> Done"
