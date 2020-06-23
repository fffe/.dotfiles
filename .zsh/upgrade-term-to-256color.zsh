# this will force TERM to a -256color variant if one exists,
# but you should really just set a correct TERM in your terminal

check_termcap_file() {
    local path=$1 term=$2
    [[ -e "$path" ]] && grep "^$term|\|$term" "$path" &>/dev/null && \
        { export TERM=$term ; return 0 }
    return 1
}

check_terminfo_directory() {
    local path=$1 term=$2
    [[ -e "$path"/$term[1]/"$term" || -e "$path/$term" ]] && { export TERM=$term; return 0 }
    return 1
}

look_for_256color() {
    [[ -n "$TERM" ]] || return
    [[ "$TERM" =~ "-256color$" ]] && return
    local TERM256="$TERM-256color"

    (( $+commands[toe] )) && toe -a | grep "^$TERM256" &>/dev/null && { export TERM=$TERM256 ; return }

    # If TERMCAP is set, only check that file
    [[ -n "$TERMCAP" ]] && check_termcap_file "$TERMCAP" "$TERM256" && return

    # If TERMPATH is set, only check the listed files
    if [[ -n "$TERMPATH" ]] {
        [[ "$TERMPATH" == *:* ]] && { tp=("${(@s/:/)TERMPATH}") } || tp=("${(@s/ /)TERMPATH}")
        for tc in $tp; do
            check_termcap_file "$tc" "$TERM256" && return
        done 
    }

    # Other file locations for Linux and *BSD
    for tc in $HOME/.termcap /etc/termcap /usr/share/misc/termcap; do
        [[ -e $tc ]] && check_termcap_file "$tc" "$TERM256" && return
    done

    for ti in $HOME/.terminfo $TERMINFO /etc/terminfo /lib/terminfo /usr/share/terminfo /usr/share/misc/terminfo; do
        check_terminfo_directory "$TERMINFO" "TERM256"
    done
}

look_for_256color
unfunction check_termcap_file
unfunction check_terminfo_directory
unfunction look_for_256color
