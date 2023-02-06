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
type dircolors >/dev/null 2>&1 && eval "$(dircolors -b)"
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

DIRSTACKSIZE=9
setopt AUTO_PUSHD

case "${OSTYPE}" in
	freebsd*|darwin*)
		AUTO_COLOR=-G
		;;
	linux*)
		AUTO_COLOR=--color=auto
		;;
esac


zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
if type "exa" > /dev/null 2>&1; then
	TIME_STYLE=--time-style=long-iso
	alias l=exa
	alias ls=exa
	alias la=exa\ -a\ $TIME_STYLE
	alias ll=exa\ -lah\ --git\ $TIME_STYLE
else
	TIME_STYLE=-D\ "%F\ %R"
	alias l=ls\ $AUTO_COLOR
	alias ls=ls\ $AUTO_COLOR
	alias la=ls\ -a\ $AUTO_COLOR
	alias ll=ls\ -lahF\ $AUTO_COLOR\ $TIME_STYLE
fi

crontab () { [[ $@ =~ -[iel]*r ]] && echo '"r" not allowed' || command crontab "$@" ;}

alias pu=pushd
alias po=popd
alias c=clear
alias g=grep\ -n $AUTO_COLOR
alias rm=rm\ -i
alias v=vim
alias vi=vim
alias vw=view
alias :q=exit
alias gsb='git status -sb'
alias gd='git diff'
alias ga='git add'
alias gc='git commit -m'
alias gl='git log --name-status --oneline `git remote`/`git symbolic-ref --short HEAD`..`git symbolic-ref --short HEAD`'
alias fuck='eval $(thefuck $(fc -ln -1))'
alias f=fuck
alias fd=fdfind
export EDITOR=vim
export MAILCHECK=0
export PATH=~/local/bin:~/.local/bin:/usr/local/bin:$PATH:/sbin
PROMPT="%B%F{cyan}%(4~|...|)%3~%F{white} %# %b%f%k"

case $TERM in
linux)
	if [ -c /dev/fb0 ]; then
		jfbterm -q -e uim-fep -u anthy
	fi
	;;
esac

