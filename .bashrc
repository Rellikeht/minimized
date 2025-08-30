# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# helpers {{{

has_exe() {
    which "$1" >/dev/null 2>/dev/null
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

# prompt {{{

# colors {{{
RESET='\[\e[0m\]'

BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
MAGENTA='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
WHITE='\[\e[0;37m\]'

LBLACK='\[\e[1;30m\]'
LRED='\[\e[1;31m\]'
LGREEN='\[\e[1;32m\]'
LYELLOW='\[\e[1;33m\]'
LBLUE='\[\e[1;34m\]'
LMAGENTA='\[\e[1;35m\]'
LCYAN='\[\e[1;36m\]'
LWHITE='\[\e[1;37m\]'
# }}}

PS2=">"
PS3=""
PS4="+"

__prompt_command() {
    # Because sometimes z.lua fucks up
    local EX="$?"
    if [ -n "$EXIT" ]; then
        EX="$EXIT"
    fi
    PS1=""
    PS1+="${MAGENTA}\w${RESET}"
    if [ "$EX" != 0 ]; then
        PS1+="${LRED}"
    else
        PS1+="${LGREEN}"
    fi
    PS1+="[$EX]${RESET}\n${LCYAN}"
    if [ "$(id -u)" -eq 0 ]; then
        PS1+="#"
    else
        PS1+="$"
    fi
    PS1+="${RESET} "
}
PROMPT_COMMAND=__prompt_command

# }}}

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

# z {{{

activate_z_lua() {
    # {{{
    # Because doing this normal way messes in some cases $?
    # Here it is exported as $EXIT
    local TEMP1 TEMP2
    TEMP1="$(mktemp)"
    TEMP2="$(mktemp)"
    cat > "$TEMP2" << 'EOF'
    --- f.orig	2024-08-06 17:50:22.159686827 +0200
    +++ f	2024-08-06 17:50:32.406544343 +0200
    @@ -55,6 +55,7 @@
     alias ${_ZL_CMD:-z}='_zlua'
     
     _zlua_precmd() {
    +    EXIT="$?"
         [ "$_ZL_PREVIOUS_PWD" = "$PWD" ] && return
         _ZL_PREVIOUS_PWD="$PWD"
         (_zlua --add "$PWD" 2> /dev/null &)
EOF
    "$@" bash once enhanced echo fzf >"$TEMP1"
    patch -u "$TEMP1" -i "$TEMP2" &>/dev/null
    rm -f "*.orig"
    eval "$(cat "$TEMP1")"
    rm "$TEMP1" "$TEMP2"
    # }}}
}

# z.lua or plain old z as fallback
ZLUA_FILE="$HOME/.local/share/z.lua/z.lua"
if [ -r "$ZLUA_FILE" ] && has_exe lua; then
    activate_z_lua lua "$ZLUA_FILE"
elif has_exe z.lua; then
    activate_z_lua z.lua --init
elif has_exe z; then
    . "$(which z)"
fi

#  }}}

# other {{{

if has_exe direnv && [ -z "$__DIRENV_LOADED" ]; then
    eval "$(direnv hook bash)"
    __DIRENV_LOADED=1
fi

#  }}}
