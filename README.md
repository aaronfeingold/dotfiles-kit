# dotfiles-kit

A small starter for **your own private dotfiles repo**: shell, tmux, vim/neovim, git, VS Code and Claude Code.
One command sets up a new Mac (Intel or Apple Silicon) or Linux box (apt or dnf).

It's a thin layer over [chezmoi](https://chezmoi.io), which does the hard parts (templating per OS/arch,
run-once scripts, diffing). This repo just gives you a sensible starting layout.

## Use it

1. Click **Use this template** → create a **private** repo (e.g. `you/dotfiles`).
2. Replace the example configs with yours (see [Adding your files](#adding-your-files)).
3. On any new machine:

   ```sh
   # private repo over SSH (key already on GitHub)
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/aaronfeingold/dotfiles-kit/main/install.sh)" -- you/dotfiles --ssh

   # or: gh auth login && gh auth setup-git, then drop --ssh
   ```

   You'll be asked for your git name, email, and whether the machine is headless (no GUI apps / VS Code).
   Existing files that get replaced are backed up to `~/.dotfiles-backup-<timestamp>/`.

## What happens

| Step | File |
|---|---|
| Install Homebrew (macOS) and packages via `brew bundle`, or `apt`/`dnf` on Linux | `home/.chezmoiscripts/run_onchange_before_10-packages.sh.tmpl` |
| Write dotfiles: `.zshrc`, `.tmux.conf`, `.gitconfig`, `~/.claude/*`, VS Code settings | `home/` |
| Install VS Code extensions | `home/.chezmoiscripts/run_onchange_after_20-vscode-extensions.sh.tmpl` |
| Clone tmux plugin manager, enable the secret-scanning git hook | `home/.chezmoiscripts/run_once_after_30-tools.sh.tmpl` |

Package and extension lists live in one place: `home/.chezmoidata/packages.yaml`. Change it, run `chezmoi apply`, and the install scripts re-run.

## Layout

```
install.sh                  bootstrap: installs chezmoi, backs up, applies
home/                       chezmoi source (see .chezmoiroot)
  .chezmoi.toml.tmpl        per-machine questions
  .chezmoidata/packages.yaml
  .chezmoiignore            skips macOS paths on Linux, GUI stuff on headless
  .chezmoiscripts/          install scripts
  .vscode-user/             ONE copy of VS Code settings, written to the right path per OS
  dot_zshrc.tmpl            → ~/.zshrc (Homebrew path picked by CPU arch)
  dot_gitconfig.tmpl        → ~/.gitconfig
  dot_tmux.conf             → ~/.tmux.conf
  dot_claude/               → ~/.claude (settings.json, CLAUDE.md, skills/)
```

chezmoi naming: `dot_x` → `.x`, `private_x` → mode 0700/0600, `.tmpl` → rendered as a [Go template](https://www.chezmoi.io/user-guide/templating/).

## Shortcuts (in the included `.zshrc`)

| Type | Does |
|---|---|
| `zrc` / `trc` / `vrc` / `nrc` / `crc` | edit zshrc / tmux.conf / vimrc / nvim / Claude settings, apply, reload |
| `dots` | cd into your dotfiles repo |
| `dsync [msg]` | commit + push everything |

The editor is VS Code (`code --wait`) on desktops and `nvim` on headless machines; change `[edit]` in `home/.chezmoi.toml.tmpl`.

## Adding your files

```sh
chezmoi add ~/.config/nvim            # start tracking a file or directory
chezmoi add --template ~/.zshrc       # track as a template (for OS/arch differences)
chezmoi edit ~/.tmux.conf             # edit the source copy
chezmoi re-add                        # pull in changes made directly to tracked files
chezmoi diff && chezmoi apply         # preview, then write
chezmoi cd && git commit -am "…" && git push
chezmoi update                        # on other machines: pull + apply
```

VS Code: edit `home/.vscode-user/settings.json` (copied as-is, not templated); it lands in
`~/Library/Application Support/Code/User` on macOS and `~/.config/Code/User` on Linux.

Claude Code: track `~/.claude/settings.json`, `CLAUDE.md`, `skills/`, `agents/`, `commands/`.
**Don't** track `~/.claude.json` (it holds auth and session state) or anything else in `~/.claude` (history, sessions, caches).

## Secrets

Never commit them. Two untracked escape hatches are already wired in:

- `~/.zshrc.local`: sourced at the end of `.zshrc` (API keys, work-only env vars)
- `~/.gitconfig.local`: included by `.gitconfig` (work email, signing key)

A pre-commit hook runs [gitleaks](https://github.com/gitleaks/gitleaks) (installed on macOS by default) on the
dotfiles repo, and CI runs it too. If you use a password manager, chezmoi can
[pull secrets from it](https://www.chezmoi.io/user-guide/password-managers/) at apply time.

## License

MIT
