# dotfiles

Personal dotfiles for macOS.

## What's included

- **git** — `.gitconfig`, `.gitignore_global`
- **zsh** — `.zshrc`, `.zprofile` (oh-my-zsh)
- **tmux** — `.tmux.conf`
- **ghostty** — `ghostty/config`
- **gh** — `gh/config.yml` (not `hosts.yml`, that's auth state, regenerate with `gh auth login`)
- **sarj** — `sarj/config.toml`
- **tmux-sessionizer** — `tmux-sessionizer/tmux-sessionizer.conf`
- **claude** — `claude/CLAUDE.md`, `claude/settings.json`, `claude/skills/`, and `claude/hooks/`, symlinked into `~/.claude`. Kept here because `~/.claude` is not a git repo and holds ~270 MB of transcripts and caches you'd never want to version.
  - `claude/hooks/agent-state.sh` tracks each Claude agent in its tmux pane and sends a macOS notification when one finishes or waits for you. `prefix + a` lists agents, `prefix + A` jumps to the one that waited longest. Notifications need a one-time permission: `open -a ~/Applications/terminal-notifier.app --args -message test`, then allow it in System Settings > Notifications.
- **raycast** — `raycast/jump-to-agent.sh`, a Raycast script command that jumps to the Claude agent that waited longest from any app. Raycast keeps its setup in its own settings, so set it up once by hand: Settings > Extensions > Script Commands > Add Directories, pick `~/dotfiles/raycast`, then give "Jump to Agent" a hotkey.
- **Makefile** — `make lint`, `make format` and `make test` for the shell and Python scripts (shellcheck, shfmt, ruff). Style settings live in `.editorconfig` and `ruff.toml`.
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
