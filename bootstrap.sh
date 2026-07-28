#!/usr/bin/env bash
# Takes a fresh Mac from nothing to ready-for-install.sh.
# Run this once on a new machine, then use install.sh for everything else
# (and again any time you want to re-apply/update).
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> Step 1: Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  echo "    already installed, skipping"
else
  xcode-select --install
  echo "    installer launched, waiting for it to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

echo "==> Step 2: Homebrew"
if command -v brew &>/dev/null; then
  echo "    already installed, skipping"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Step 3: handing off to install.sh"
"$DOTFILES/install.sh"

echo "==> Done"
