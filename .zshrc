setopt ALWAYS_TO_END        # move cursor to the end of the word after completion
setopt AUTO_PUSHD           # automatically add the previous directory to the stack when the directory is changed
setopt COMPLETE_IN_WORD     # complete from both ends of a word
setopt CORRECT              # try to correct typos in commands
setopt EXTENDED_GLOB        # adds #, ~ and ^ to globbing
setopt EXTENDED_HISTORY     # adds timestamps and duration to history file
setopt HIST_FCNTL_LOCK      # use fcntl for locking histfile, if available
setopt HIST_FIND_NO_DUPS    # ignore duplicate commands while searching history
setopt HIST_NO_STORE        # son't save "history" in the history
setopt HIST_REDUCE_BLANKS   # get rid of unnecessary whitespace
setopt INC_APPEND_HISTORY   # append commands to the shared history immediately, rather than on shell exit
setopt PUSHD_IGNORE_DUPS    # don't add duplicate entries to the stack
setopt PUSHD_SILENT         # don't print directory stack after pushd/popd
setopt PUSHD_TO_HOME        # "pushd" == "pushd $HOME" 

export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
export HISTSIZE=5000
export SAVEHIST=5000

# try to force 256 colors
[[ -e ${ZDOTDIR:-$HOME}/.zsh/upgrade-term-to-256color.zsh ]] && \
    source ${ZDOTDIR:-$HOME}/.zsh/upgrade-term-to-256color.zsh
 
# default less options:
# -M    very verbose prompts
# -i    case-insensitive searches
# -c    full screen repaints are painted from the top line down
# -e    automatically exit the second time less reaches end-of-file
# -R    don't sanitize ansi color escape sequences
export LESS=MiceR

# match ls colors for GNU and BSD ls
export LSCOLORS="ExGxFxdaCxDaDahbadacec"
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:"

# colorize less (and man etc.)
export LESS_TERMCAP_mb=$'\E[1;33m'
export LESS_TERMCAP_md=$'\E[1;33m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[0;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[4;32m'

# match grep colors (black on yellow) for GNU and BSD grep
export GREP_COLOR="30;43"
export GREP_COLORS="mt=$GREP_COLOR"

# force ls/grep color
case $OSTYPE {
    linux*)
        [[ -x dircolors ]] && eval `dircolors`
        alias egrep="egrep --color=auto"
        alias fgrep="fgrep --color=auto"
        alias grep="grep --color=auto"
        alias ls="ls --color=auto -N -F"
        ;;
    freebsd*|darwin*)
        export CLICOLOR="YES"
        alias egrep="egrep --color=auto"
        alias fgrep="fgrep --color=auto"
        alias grep="grep --color=auto"
        alias ls="ls -G -F"
        ;;
    solaris*)
        (( $+commands[ggrep] )) && alias grep="ggrep --color=auto"
        (( $+commands[gegrep] )) && alias egrep="gegrep --color=auto"
        (( $+commands[gfgrep] )) && alias fgrep="gfgrep --color=auto"
        ;;
}

# when escape is pressed twice:
#   - if there is a command in the buffer, prefix it with sudo
#   - if there is no command in the buffer, prefix the last command with sudo
sudo-cmd() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != su(do|)\ * ]] && LBUFFER="sudo $LBUFFER"
}
zle -N sudo-cmd
bindkey -r "\e"
bindkey "\ee" vi-cmd-mode
bindkey "\e\e" sudo-cmd

# load colors, completion, and url quoting
autoload -Uz colors && colors
autoload -Uz compinit && compinit
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

# load the theme
[[ -d ${ZDOTDIR:-$HOME}/.zsh/prompts ]] && {
    fpath=(${ZDOTDIR:-$HOME}/.zsh/prompts $fpath)
    autoload -Uz promptinit && promptinit && prompt helloworld
}

# load functions
[[ -d ${ZDOTDIR:-$HOME}/.zsh/functions ]] && {
    fpath=(${ZDOTDIR:-$HOME}/.zsh/functions $fpath)
    for func in ${ZDOTDIR:-$HOME}/.zsh/functions/*; do autoload -z ${func:t} ; done
}

# enable zsh-history-substring-search
[[ -e ${ZDOTDIR:-$HOME}/.zsh/zsh-history-substring-search.zsh ]] && {
    source ${ZDOTDIR:-$HOME}/.zsh/zsh-history-substring-search.zsh

    # black on yellow for history matches
    export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold,underline'
    export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,underline'

    zmodload zsh/terminfo
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
}

# enable zsh-autosuggestions
[[ -e ${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions.zsh ]] && {
    source ${ZDOTDIR:-$HOME}/.zsh/zsh-autosuggestions.zsh

    # black on yellow for history matches
    #export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
    export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)
    export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=60
    export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
    bindkey '^ ' autosuggest-accept
}

# some completion defaults
zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle -e ':completion:*' hosts 'reply=()'
zstyle -e ':completion:*' users 'reply=()'
zstyle ':completion:*' force-list always
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\n%F{yellow}%d:%f'
zstyle ':completion:*:warnings' format '%F{red}No match.%f'
zstyle ':completion:*:corrections' format '%F{green}Match: %d (errors: %e)%f'

# nicer kill completion, gnu/bsd/sol compatible ps
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,pcpu,tty,time,args'
zstyle ':completion:*:processes' list-colors "=(#b) #([0-9]#)*=00=36"
zstyle ':completion:*:kill:*' insert-ids single
zstyle ':completion:*:kill:*' menu yes select
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes

# fuzzy match mistyped completions
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# nicer man completion
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# load local configuration if it exists
[[ -e ${HOME}/.zshrc.local ]] && source ${HOME}/.zshrc.local
