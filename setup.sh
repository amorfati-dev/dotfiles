#!/bin/bash
# Compatible with the Bash 3.2 included with macOS.
set -euo pipefail

usage() {
  cat <<'HELP'
Usage: ./setup.sh [--apply] [--install-apps] [--target-home PATH]

Preview the configuration links by default; a preview changes nothing.

  --apply             Create links, backing up existing files first.
  --install-apps      Also run Homebrew Bundle (requires --apply and real home).
  --target-home PATH  Use an existing directory instead of your home.
  -h, --help          Show this help.

Homebrew must already be installed to use --install-apps. Backups are kept
under the target home's .local/state/dotfiles/backups directory.
HELP
}

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

apply=false
install_apps=false
target_home="${HOME:?HOME must be set}"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) apply=true; shift ;;
    --install-apps) install_apps=true; shift ;;
    --target-home)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail '--target-home needs a directory.'
      target_home="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1 (use --help)." ;;
  esac
done

if "$install_apps" && ! "$apply"; then
  fail '--install-apps requires --apply.'
fi
[ -d "$target_home" ] || fail "Target home is not an existing directory: $target_home"
target_home="$(CDPATH= cd -- "$target_home" && pwd -P)"
[ "$target_home" != / ] || fail 'The filesystem root cannot be a target home.'
if "$install_apps"; then
  real_home="$(CDPATH= cd -- "$HOME" && pwd -P)"
  [ "$target_home" = "$real_home" ] || fail '--install-apps cannot be used with an alternate target home; Homebrew changes this Mac.'
fi
repo_dir="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
backup_root="$target_home/.local/state/dotfiles/backups"
backup_dir=''

sources=(
  'zsh/.zshrc' 'zsh/.zprofile' 'git/config' 'git/ignore'
  'starship/starship.toml' 'ghostty/config' 'nvim' 'tmux/.tmux.conf'
  'aerospace' 'sketchybar' 'karabiner' 'atuin/config.toml' 'htop/htoprc'
)
destinations=(
  '.zshrc' '.zprofile' '.gitconfig' '.config/git/ignore'
  '.config/starship.toml' '.config/ghostty/config' '.config/nvim' '.tmux.conf'
  '.config/aerospace' '.config/sketchybar' '.config/karabiner'
  '.config/atuin/config.toml' '.config/htop/htoprc'
)

# Refuse symlinked parent directories, even when they point inside the home.
# That keeps writes and backups within the selected home without following links.
check_parent() {
  local relative="$1" current="$target_home" component
  local -a components
  case "$relative" in
    */*) relative="${relative%/*}" ;;
    *) return 0 ;;
  esac
  IFS=/ read -r -a components <<< "$relative"
  for component in "${components[@]}"; do
    current="$current/$component"
    [ ! -L "$current" ] || fail "Parent directory is a symlink: $current"
    if [ -e "$current" ] && [ ! -d "$current" ]; then
      fail "Parent path is not a directory: $current"
    fi
  done
}

# Finish checks before changing anything.
for i in "${!sources[@]}"; do
  [ -f "$repo_dir/${sources[$i]}" ] || [ -d "$repo_dir/${sources[$i]}" ] || fail "Missing configuration: ${sources[$i]}"
  check_parent "${destinations[$i]}"
done
check_parent '.local/state/dotfiles/backups/placeholder'
if "$install_apps"; then
  command -v brew >/dev/null 2>&1 || fail 'Install Homebrew first, then run this again.'
  [ -f "$repo_dir/Brewfile" ] || fail 'The repository has no Brewfile.'
fi

if ! "$apply"; then
  printf 'Preview only. Use --apply to make these changes.\n'
fi
for i in "${!sources[@]}"; do
  source_path="$repo_dir/${sources[$i]}"
  relative_destination="${destinations[$i]}"
  destination="$target_home/$relative_destination"
  if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source_path" ]; then
    printf 'Already linked: %s\n' "$destination"
    continue
  fi
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if "$apply"; then
      if [ -z "$backup_dir" ]; then
        mkdir -p "$backup_root"
        backup_dir="$(mktemp -d "$backup_root/$(date '+%Y%m%d-%H%M%S').XXXXXX")"
      fi
      backup_path="$backup_dir/$relative_destination"
      mkdir -p "$(dirname "$backup_path")"
      mv "$destination" "$backup_path"
      printf 'Backed up: %s -> %s\n' "$destination" "$backup_path"
    else
      printf 'Would back up: %s (under %s)\n' "$destination" "$backup_root"
    fi
  fi
  if "$apply"; then
    mkdir -p "$(dirname "$destination")"
    ln -s "$source_path" "$destination"
    printf 'Linked: %s -> %s\n' "$destination" "$source_path"
  else
    printf 'Would link: %s -> %s\n' "$destination" "$source_path"
  fi
done

if "$install_apps"; then
  brew bundle --file "$repo_dir/Brewfile" --no-upgrade
fi
if "$apply"; then
  printf 'Setup complete. Open a new terminal to load the shell settings.\n'
fi
