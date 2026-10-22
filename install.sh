#!/bin/sh
# Bootstrap a machine from a chezmoi dotfiles repo.
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/aaronfeingold/dotfiles-kit/main/install.sh)" -- <github-user>[/<repo>] [chezmoi init flags]
#
# Private repo? Add --ssh (needs an SSH key on GitHub) or run `gh auth login && gh auth setup-git` first.
# Any extra flags are passed to `chezmoi init`, e.g. --promptBool headless=true
set -eu

if [ $# -lt 1 ]; then
  echo "usage: install.sh <github-user>[/<repo>] [chezmoi init flags]" >&2
  exit 1
fi

bin_dir="$HOME/.local/bin"
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi=$(command -v chezmoi)
else
  echo "==> installing chezmoi to $bin_dir"
  mkdir -p "$bin_dir"
  sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  chezmoi="$bin_dir/chezmoi"
fi

echo "==> cloning $1"
"$chezmoi" init "$@"

# Back up any existing files chezmoi is about to replace.
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
"$chezmoi" managed --include=files --path-style=relative | while IFS= read -r f; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mkdir -p "$backup/$(dirname "$f")"
    cp -p "$HOME/$f" "$backup/$f"
  fi
done
[ -d "$backup" ] && echo "==> existing files backed up to $backup"

echo "==> applying"
"$chezmoi" apply

echo "==> done. Open a new shell. Edit with: chezmoi edit <file>, sync with: chezmoi update"
