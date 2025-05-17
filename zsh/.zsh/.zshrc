
# ~/.zshrc

# 1) Point at Oh My Zsh installation
export ZSH="$HOME/.config/zsh/oh-my-zsh"

# 2) Use the basic theme
ZSH_THEME="robbyrussell"

# 3) No plugins for now
plugins=()

# 4) Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# 5) colors() function from your old ~/.bashrc
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

# 6) Your aliases
alias ls='ls --color=auto'
alias la='ls -a'
alias h='cd'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias c='xclip -selection clipboard'
