# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# helpers {{{

has_exe() {
    /usr/bin/env which "$1" >/dev/null 2>/dev/null
}

source_if_exists() {
    [ -f "$1" ] && source "$1"
}

eval_if_exists() {
    [ -f "$1" ] && . "$1"
}

#  }}}

# settings {{{

stty -ixon 2>/dev/null

# nice history settings
HISTCONTROL=ignoredups:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# just in case
shopt -s expand_aliases

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#  }}}

# aliases {{{

alias ls='ls --color=auto'
alias ll='ls -la'

alias grep='grep --color=auto'
alias fgrep='grep -F'
alias egrep='grep -E'

eval_if_exists "$HOME/.bash_aliases"

#  }}}

# conda {{{

if has_exe micromamba; then
    eval "$(micromamba shell hook -s bash)"
elif has_exe conda; then
    __conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi

#  }}}

if has_exe fzf; then #  {{{
    eval "$(fzf --bash)"
    export FZF_COMPLETION_TRIGGER='**'
    export FZF_DEFAULT_OPTS="
    --preview-window 'top:60%'
    --height=100%
    --history='$HOME/.fzf-hist'
    --bind 'alt-k:preview-up,alt-j:preview-down'
    --bind 'ctrl-k:kill-line,ctrl-j:jump'
    --bind 'ctrl-s:change-preview-window(hidden|)'
    --bind 'alt-K:preview-half-page-up,alt-J:preview-half-page-down'
    --bind 'alt-U:half-page-up,alt-D:half-page-down'
    --bind 'ctrl-c:cancel,ctrl-g:clear-selection'
    --bind 'alt-p:prev-history,alt-n:next-history'
    --bind 'alt-P:prev-selected,alt-N:next-selected'
    --bind 'ctrl-p:up,ctrl-n:down'
    --bind 'ctrl-t:toggle'
    "
fi #  }}}

# other {{{

ZLUA_FILE="$HOME/.local/share/z.lua/z.lua"
if [ -r "$ZLUA_FILE" ] && has_exe lua; then
    eval "$(lua "$ZLUA_FILE" --init bash enhanced once echo)"
elif has_exe z.lua; then
    eval "$(z.lua --init bash enhanced once echo)"
fi

if has_exe direnv && [ -z "$__DIRENV_LOADED" ]; then
    eval "$(direnv hook bash)"
    __DIRENV_LOADED=1
fi

#  }}}
