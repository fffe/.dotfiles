export LANG="en_US.UTF-8"
export TIMEFMT=$'real\t%*Es\nuser\t%*Us\nsys \t%*Ss\ncpu \t%P'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${ZDOTDIR:-$HOME}/bin

# This function will set the environment variable in ARG1 to the first of
# ARG2..N that is found.
function __set_if_found() {
        local env_var=$1
        shift
        for i in $*; do
        (( $+commands[$i] )) && { export $env_var=$i ; return 0 }
        done
        return 1
}

__set_if_found EDITOR vim vi nano pico
__set_if_found BROWSER links lynx w3m
__set_if_found PAGER less more
export READNULLCMD=$PAGER

unfunction __set_if_found
