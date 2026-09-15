#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

## True screen clearing
function clear() {
    echo -en "\033c"
}

## use bat instead of cat if available
function cat() {
    bat -L | grep -qm1 "[,:]${1##*.}($|,)"
    if [[ -t 0 ]] && [[ $# == 1 ]] && _e bat && bat -L | grep -q "${1##*.}"; then
        command bat --color always --decorations never -P "$@"
    else
        command cat "$@"
    fi
}

##  +-+-+-+-+-+ +-+-+-+-+
##  |S|p|i|c|y| |G|r|e|p|
##  +-+-+-+-+-+ +-+-+-+-+
## This makes grep run without the extra arguments unless it's being either piped:
##   cat $HOME/.bashrc | grep "LESS"
## or normally ran interactively:
##   grep $HOME/.bashrc "^export"
## This way it'll work for <(grep ..) or var=$(grep ..) or echo '' | grep
## but won't affect scripts or other complex command chains.
##
## It also fixes errors when stupid programs like adb or docker use grep
## to filter autocompletion results screwing the list when pressing TAB.
##
## This is a replacement for the old 'alias grep="grep -n -C 2 $_COLOR_ALWAYS_ARG -E"'
function grep {
    if [ -t 0 ] || [ -t 1 ]; then
        command grep -n -C 2 $_COLOR_ALWAYS_ARG -E "$@"
    elif { [ "$(LC_ALL=C stat -c %F - <&3)" = fifo ]; } 3>&1 ||
        [ "$(LC_ALL=C stat -c %F -)" = fifo ] ||
        [ -t 2 ]; then
        # t -2 fixes adb -s [TAB] and other autocompletion
        command grep "$@"
    else
        command grep "$@"
    fi
}

##  +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
##  |O|v|e|r|r|i|d|i|n|g| |A|l|i|a|s|e|s|
##  +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
## Makes diff decent
if _e colordiff; then
    alias diff="colordiff -B -U 5 --suppress-common-lines"
else
    alias diff="diff $_COLOR_ALWAYS_ARG -B -U 5 --suppress-common-lines"
fi

## Colors on DF
alias df="${GRC}df -H"
## Makes dd pretty and with progress bar
alias dd="${GRC}dd status=progress oflag=sync"
## Makes ccze not stupid (fast and no output clearing)
_e "ccze" && alias ccze='ccze -A -o nolookups'

##  +-+-+-+-+ +-+-+
##  |I|Q|4|7| |R|M|
##  +-+-+-+-+ +-+-+
## Safe rm using gio trash
## Falls back to rm in any unsupported case
## Only caveat: ignores -r as gio trash already
## does it recursively without choice
if _e gio; then
    function rm() {
        use_gio=true
        local argv=("$@")
        for index in "${!argv[@]}"; do
            if [[ ${argv[$index]} == '-r' || ${argv[$index]} == '-R' ]]; then
                unset -v 'argv[$index]'
            elif [[ ${argv[$index]} =~ ^-{1}[^-]?[rR] ]]; then
                argv[$index]=${argv[$index]//[Rr]/}
                echo "new argv is ${argv[$index]}"
            fi
            if [[ ${argv[$index]} =~ ^-[^f] && ${argv[$index]} != "--force" ]]; then
                echo "keep argv is ${argv[$index]}"
                use_gio=false
            fi
        done

        if $use_gio; then
            if gio trash "${argv[@]}" 2>/dev/null; then
                echo "Sent to Trash (gio)."
                return 0
            else
                echo "Gio failed, trying rm ${*}."
            fi
        fi
        command rm "${@}"
    }
fi
