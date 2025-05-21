# ─── Instant prompt preamble (top of file) ─────────────────────────────────
# (suppress warnings by uncommenting the next line)
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh My Zsh core setup (no console I/O before this) ──────────────────────
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="${ZDOTDIR:-$HOME/.config/zsh}/oh-my-zsh"


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

# ─── Powerlevel10k configuration ───────────────────────────────────────────
# (only if you want to override defaults)
[[ ! -f "${ZSH_CUSTOM:-$ZSH/custom}/themes/powerlevel10k/powerlevel10k.zsh" ]] \
  || source "${ZSH_CUSTOM:-$ZSH/custom}/themes/powerlevel10k/powerlevel10k.zsh"

# ─── zoxide rebinding & NVM ─────────────────────────────────────────────────
eval "$(zoxide init zsh --cmd j)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]      && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ─── colors() helper from your old bashrc ───────────────────────────────────
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

# ─── Your aliases ───────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias la='ls -a'
alias h='cd'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias c='xclip -selection clipboard'
alias notes='nvim ~/documents/Main'
alias s='tree | ripgrep '

# ─── Cargo bin, broot hook, history, keybindings ────────────────────────────
export PATH="$HOME/.cargo/bin:$PATH"

if [[ -s "$HOME/.config/broot/launcher/bash/br" ]]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

export HISTFILE="$HOME/.histfile"
HISTSIZE=1000
SAVEHIST=1000

bindkey -e

# ─── Compinit (tab-completion) ──────────────────────────────────────────────
zstyle :compinstall filename "$ZDOTDIR/.zshrc"
autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
