# Interactive shell settings, based on Martin's existing configuration.
[[ -o interactive ]] || return

typeset -U path PATH
path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.local/opt/go/bin" ]] && path+=("$HOME/.local/opt/go/bin")
[[ -d "$HOME/.grok/bin" ]] && path=("$HOME/.grok/bin" $path)

# Keep the current vi-style keyboard bindings.
bindkey -v

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# Completion and the optional existing Grok CLI completion directory.
[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)
autoload -Uz compinit
compinit

# Preserve aliases only when their tools are available.
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first'
  alias la='eza -a --icons'
  alias tree='eza --tree --icons'
fi
(( $+commands[bat] )) && alias cat='bat'

# Load each integration once; a new Mac can open a shell before apps are installed.
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

[[ -r "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"

# API keys and other private overrides go here, outside this repository.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Optional system information banner: enable with DOTFILES_SHOW_SYSTEM_INFO=1
# in ~/.zshrc.local. Avoid launching background animations at shell startup.
if [[ ${DOTFILES_SHOW_SYSTEM_INFO:-0} == 1 ]] && (( $+commands[fastfetch] )); then
  fastfetch
fi

if (( $+commands[brew] )); then
  _dotfiles_brew_prefix="$(brew --prefix)"
  [[ -r "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # Syntax highlighting must load last.
  [[ -r "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  unset _dotfiles_brew_prefix
fi
