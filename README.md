# Martin's dotfiles

My Mac setup recipe: Homebrew tools and apps, Zsh, Git, Starship, and Ghostty.
These files help set up a fresh Mac and keep changes to my preferences in Git.
Documents, photos, app data, passwords, and account sessions need their own backup.

## What's included

| File | Purpose |
| --- | --- |
| `Brewfile` | Homebrew-managed tools, apps, fonts, and taps recorded on 2026-09-14 |
| `zsh/.zprofile` | Homebrew and local executable paths for Apple Silicon or Intel |
| `zsh/.zshrc` | Existing aliases, vi key bindings, completion, and shell integrations |
| `git/config` | Main as the default branch, rebase on pull, and Delta diffs |
| `git/ignore` | Global ignores for macOS metadata and editor temporary files |
| `starship/starship.toml` | My current Starship prompt appearance |
| `ghostty/config` | Catppuccin Mocha, JetBrainsMono Nerd Font, and font size 14 |
| `examples/` | Templates for private settings that stay outside Git |
| `setup.sh` | Preview changes, back up conflicts, and link the six configuration files |

The shell configuration consolidates repeated initialization commands from the
old setup. Starship is the active prompt. Legacy Powerlevel10k and Oh My Zsh startup
blocks and background Matrix animations are omitted. The Brewfile still records
installed Powerlevel10k for reference. The system information banner is optional.
Oh My Zsh's extra aliases are not bundled; the explicit `eza` and `bat` aliases are.

## Set up a new Mac

1. Finish macOS setup, sign in to your accounts, and restore personal files from
   your separate backup. Make sure you can access your password manager.
2. Install Apple's command-line tools if needed:

   ```sh
   xcode-select --install
   ```

3. Install Homebrew using the instructions at [brew.sh](https://brew.sh), including
   the shell setup steps it prints. Homebrew is required for the app installation.
4. Download this repository into a permanent workspace location:

   ```sh
   mkdir -p "$HOME/workspace/martin"
   git clone https://github.com/amorfati-dev/dotfiles.git "$HOME/workspace/martin/dotfiles"
   cd "$HOME/workspace/martin/dotfiles"
   ```

5. Read the `Brewfile` and remove anything you no longer want, then install it:

   ```sh
   brew bundle --file=Brewfile --no-upgrade
   ```

   This can download large apps and may ask for macOS permissions. Packages follow
   Homebrew's available versions; the list does not pin every version. Background
   services are not automatically started by this Brewfile. Some GUI apps may
   require your approval when first launched.

6. Preview the configuration changes, then apply them:

   ```sh
   ./setup.sh
   ./setup.sh --apply
   ```

7. Set up your Git identity in a local file:

   ```sh
   test -e "$HOME/.gitconfig.local" || cp examples/gitconfig.local.example "$HOME/.gitconfig.local"
   nano "$HOME/.gitconfig.local"
   ```

   Replace both placeholders. For public commits, get your exact GitHub noreply
   address from [GitHub email settings](https://github.com/settings/emails).
   Your name and address will be part of the commits you create.

8. If needed, copy `examples/zshrc.local.example` to `~/.zshrc.local` and add
   private or machine-specific settings. Retrieve credentials from your password
   manager; keep the local file outside the repository. Do not overwrite an
   existing local override. `~/.zprofile.local` is also supported for login settings.
9. Open a new terminal and Ghostty. Sign into GitHub (`gh auth login`), Atuin, and
   other tools you use. Install apps not managed through Homebrew separately,
   restore their data, and grant permissions such as Accessibility when required.

## How setup works

Running `./setup.sh` with no arguments is a preview and does not write anything.
`--apply` creates symbolic links: apps read their usual configuration filenames,
which point to the files in this repository. Keep the repository in place after
applying it. Editing a linked file also edits the copy tracked by Git.

Existing files, directories, and symlinks at the six destinations are moved to a
unique folder under `~/.local/state/dotfiles/backups/` before replacement. The
script prints each backup location. Already-correct links are left alone, so it
can be run again. Symlinked parent directories are refused to avoid writing into
an unexpected location. The installer currently uses `~/.config`; adapt it first
if you use a custom `XDG_CONFIG_HOME`.

To undo an applied setting, remove only the corresponding symlink and move its
saved original back to the original location. If no original existed, removing
the symlink is enough. Open a new terminal after reverting shell files. Backups
may contain private settings; keep them local.

`./setup.sh --apply --install-apps` can also run Homebrew Bundle after linking.
For a first setup, the separate steps above make it easier to see what is happening.
The script never installs Homebrew itself or changes macOS system preferences.

## Keep it current

When changing settings, review and commit the changes you want to keep:

```sh
git status
git diff
git add zsh/.zshrc  # choose the specific files you reviewed
git diff --cached
git commit -m "Update shell preferences"
git push
```

To capture a fresh Homebrew list without overwriting the current one immediately:

```sh
brew bundle dump --file=Brewfile.next --formula --cask --tap --no-describe --no-restart
diff -u Brewfile Brewfile.next
```

Review the differences, then replace `Brewfile` with the new list if desired.
Delete or rename a leftover `Brewfile.next` before generating another snapshot.
Homebrew records requested packages and resolves their dependencies during install.
If it reports stale dependency metadata, review that separately before relying on
the snapshot; this repository does not repair the existing installation.

## Public repository boundaries

Keep passwords, tokens, SSH private keys, `.env` files, shell history, app databases,
private hostnames, and personal documents out of Git. The original shell files
and Git identity were not copied wholesale. `.gitignore` is a convenience, not a
secret scanner; it cannot protect a secret added to a tracked file or remove
something already committed. Review `git diff --cached` before every commit.

The initial creation does not activate these settings on the current Mac. More
app preferences, editor settings, and macOS preferences can be added deliberately
later after checking their contents.

## Verification

The installer is compatible with macOS's bundled Bash 3.2. Its regression tests
use temporary fixture directories and never install applications:

```sh
python3 -m unittest discover -s tests -v
```

Links and backups can also be tried manually with an existing temporary directory:

```sh
test_home="$(mktemp -d)"
./setup.sh --target-home "$test_home"
./setup.sh --apply --target-home "$test_home"
```

App installation is refused for an alternate target home because it would still
affect the real Mac. A full rebuild on a fresh Mac has not yet been tested.

References: [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile),
[Git configuration](https://git-scm.com/docs/git-config), and
[GitHub guidance on sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).
