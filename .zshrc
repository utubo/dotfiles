# vvv Default vvv

# Set up the prompt

autoload -Uz promptinit
promptinit
#prompt adam1


setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ^^^ Default ^^^
# vvv My Config vvv

case "${OSTYPE}" in
	freebsd*|darwin*)
		AUTO_COLOR=-G
		;;
	linux*)
		AUTO_COLOR=--color=auto
		;;
esac
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
alias ls=ls\ $AUTO_COLOR
alias ll=ls\ -lFh $AUTO_COLOR
alias la=ls\ -alFh $AUTO_COLOR
alias g=grep\ $AUTO_COLOR
alias rm=rm\ -i
alias c=clear
alias v=vim
alias vw=view
alias :q=exit
alias gd=git\ diff
alias fuck='eval $(thefuck $(fc -ln -1))'
alias f=fuck
export EDITOR=vim
export MAILCHECK=0
export PATH=~/local/bin:$PATH
PROMPT="%B%F{green}%n %B%F{cyan}%(4~|...|)%3~%F{white} %# %b%f%k"

