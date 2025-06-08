# ~/.config/zsh/.zshrc

# ─── 1. Oh My Zsh core setup ─────────────────────────────────────────────────────
export ZSH="${ZDOTDIR:-$HOME/.config/zsh}/oh-my-zsh"
ZSH_THEME="robbyrussell"  # Default theme (no Powerlevel10k)
plugins=(
  fzf
  extract
  copyfile
  zsh-syntax-highlighting
  zsh-autosuggestions
  zoxide
  vi-mode
)
source "$ZSH/oh-my-zsh.sh"

# ─── 2. zoxide & NVM initialization ─────────────────────────────────────────────
eval "$(zoxide init zsh --cmd j)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]         && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ─── 3. Helpers & Functions ─────────────────────────────────────────────────────
colors() {
  local fgc bgc vals seq0
  printf "Color escapes are %s\n" '%{\e[${value};...;${value}m%}'
  printf "Values 30..37 are %F{yellow}foreground colors%f\n"
  printf "Values 40..47 are %K{yellow}background colors%k\n"
  printf "Value  1 gives a %Bbold-faced look%b\n\n"
  for fgc in {30..37}; do
    for bgc in {40..47}; do
      fgc=${fgc#37}; bgc=${bgc#40}
      vals="${fgc:+$fgc;}${bgc}"; vals=${vals%%;}
      seq0="%{\e[${vals}m%}"
      printf "  %-9s" "${seq0:-(default)}"
      printf " ${seq0}TEXT%{\e[m%}"
      printf " %{\e[${vals:+${vals};}1m%}BOLD%{\e[m%}"
    done
    print "\n"
  done
}

# ─── 4. Aliases ─────────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias la='ls -a'
alias h='cd'
alias y='yazi'
alias b='bluetui'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias c='wl-copy'
alias notes='nvim ~/documents/Main'
alias s='tree | ripgrep'
alias n='nvim'
alias f='clear'
alias m='mpv --hwdec=vaapi --vo=gpu --gpu-context=wayland'
# ─── 5. PATH & broot hook ─────────────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$PATH"
if [[ -s "$HOME/.config/broot/launcher/bash/br" ]]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

# ─── 6. History configuration & auto-repair ────────────────────────────────────
export HISTFILE="$HOME/.histfile"
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory        # append, don’t overwrite
setopt incappendhistory     # write immediately
setopt sharehistory         # share across sessions

# Auto-repair corrupt history on startup
if [[ -s "$HISTFILE" ]]; then
  fc -R "$HISTFILE" 2>/dev/null && fc -W "$HISTFILE" 2>/dev/null
fi

# ─── 7. Keybindings & completion ─────────────────────────────────────────────────
bindkey -e
autoload -Uz compinit
compinit



# tell Starship exactly where your config lives
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

source "$HOME/projects/volcanite/vulkan/1.4.313.0/setup-env.sh"

# …later, your existing Starship init…
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ─── End of file ─────────────────────────────────────────────────────────────────
