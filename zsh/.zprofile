# Homebrew supports both Apple Silicon and Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Keep paths portable when the Mac or account name changes.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# Machine-specific login settings are deliberately outside this repository.
if [[ -r "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
