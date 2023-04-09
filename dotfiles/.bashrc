#!/usr/bin/env bash
#                          .         .
##  /$$$$$$$$               /$$ /$$              /$$$$$$$   /$$$$$$   /$$$$$$  /$$   /$$ /$$$$$$$   /$$$$$$
## | $$_____/              |__/| $/             | $$__  $$ /$$__  $$ /$$__  $$| $$  | $$| $$__  $$ /$$__  $$
## | $$       /$$$$$$/$$$$  /$$|_//$$$$$$$      | $$  \ $$| $$  \ $$| $$  \__/| $$  | $$| $$  \ $$| $$  \__/
## | $$$$$   | $$_  $$_  $$| $$  /$$_____/      | $$$$$$$ | $$$$$$$$|  $$$$$$ | $$$$$$$$| $$$$$$$/| $$
## | $$__/   | $$ \ $$ \ $$| $$ |  $$$$$$       | $$__  $$| $$__  $$ \____  $$| $$__  $$| $$__  $$| $$
## | $$      | $$ | $$ | $$| $$  \____  $$      | $$  \ $$| $$  | $$ /$$  \ $$| $$  | $$| $$  \ $$| $$    $$
## | $$$$$$$$| $$ | $$ | $$| $$  /$$$$$$$/      | $$$$$$$/| $$  | $$|  $$$$$$/| $$  | $$| $$  | $$|  $$$$$$/
## |________/|__/ |__/ |__/|__/ |_______/       |_______/ |__/  |__/ \______/ |__/  |__/|__/  |__/ \______/

##  +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
##  |D|e|b|u|g|g|i|n|g| |I|n|f|o|
##  +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
## Perf. optimization: https://stackoverflow.com/questions/18039751/how-to-debug-a-bash-script-and-get-execution-time-per-command
## Uncomment the first to enable debug mode, the second to optimize performance
# PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
# date +%s%N > /tmp/bash_last_debug; export PS4='+[$(P=$(date +%s%N) && N=$(cat /tmp/bash_last_debug) && echo "$(((P-N)/1000000))ms" && echo $P > /tmp/bash_last_debug)][${BASH_SOURCE}:${LINENO}]: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'; set -x;

##  +-+-+-+-+
##  |I|n|i|t|
##  +-+-+-+-+
## If not running interactively, don't do anything
[[ $- != *i* ]] && return
## Used for version checking

export _RCVERSION=27
function _changelog() {
    local c=$'\e[37;03m'       # cyan
    local r=$'\e[00m'          # reset
    local b=$'\e[1m'           # bold
    local y=$'\e[33;01m'       # yellow
    local i=$'\e[00m\e[96;03m' # italic
    local g=$'\e[32;01m'       # green
    echo "${g}emi's .bashrc${r}
${y}Changelog v27 (2023-09-04)${r}" | sed -e :a -e "s/^.\{1,$(($(tput cols) + 10))\}$/ & /;ta"
    echo -e "
  ${b}- Fixed home directories with spaces in the path${r}

  ${i}\e]8;;https://www.youtube.com/watch?v=dQw4w9WgXcQ\aHello GHSASH\e]8;;\a Tip: type the beginning of a command (e.g.: echo) and press arrow-up to browse it's history.${r}"
}
# ${y}Version 23 (2022-12-27):${r}
# - ${b}${i}New feature!${r} You can now easily measure the performance of a command:
#     - Usage: ${c}profile_command number_of_times 'command [args]'${r}
#     - Example: ${c}profile_command 10 'sleep 1'${r}
#     - This will run ${c}'sleep 1'${r} 10 times and print a summary of the results. Try it out!
# - Colors for git repositories changed and are now more consistent:
#     - Fixed an issue when you were inside a git repo directory that was a symbolic link.
#     - If you're inside a git repository, the path will be colored in violet, just like the username and hostname.
#       Additionally, if the current working directory is a subdirectory of a git repo, it will be highlighted in bold.
#       Expect more changes to git features in the future, specially on performance and in the current branch preview.
# - Colors for the current working directory changed, it's not bold anymore and it's a light blue. This is to make it
#   more consistent with the git repo path color change.
# - Fixed a bug in which some terminals would not display grey colors, so changed those to white.
# - Fixed history grepper function:
#     - Type ${c}h any.*regex${r} to search for any regex in your history
#     - Type ${c}h 00000${r} to show context around a particular entry

function check_updates() {
    if [[ $(($(date +%s) - $(cat "$HOME/.emishrc_last_check"))) -gt 86400 ]]; then
        date +%s >"$HOME/.emishrc_last_check"

        _RCREMOTE=$(curl -sL https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/.bashrc | grep -m1 'export _RCVERSION=' | sed 's/[^0-9]*//g;s/^0//')
        if [ $(($_RCREMOTE - $_RCVERSION)) -gt 0 ]; then # needs single brackets for leading zeroes to work
            # echo -en "\E[01;35mThere's an update for emishrc available! Updating..."
            rm "$HOME/.emishrc_last_check"
            curl -sL https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/autoinstall.sh | bash -s -- --quiet
        fi
    fi
}

check_updates 2>/dev/null &

## Returns if the current shell is a SSH shell.
# @see https://unix.stackexchange.com/a/12761
function is_ssh() {
    # For windows or other weird systems:
    if [[ ! -f /proc/1/stat ]]; then
        return 1
    fi
    p=${1:-$PPID}
    read pid name x ppid y < <(cat /proc/$p/stat)
    # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p)
    [[ "$name" =~ sshd ]] && { return 0; }
    [[ "$ppid" -le 1 ]] && { return 1; }
    is_ssh $ppid
}

## Checks if a binary or built-in command exists on PATH with failovers
function _e() {
    (hash "$1" >&/dev/null && return 0) ||
        ([[ $(command -v "$1" >&/dev/null) == "$1" ]] && return 0) ||         # returns true for aliases therefore the ==
        (which --skip-alias --skip-functions "$1" >&/dev/null && return 0) || # doesn't work with built-ins
        return 1
}

## Checks if a binary or built-in command exists and has color support
function _c() {
    if (
        (hash "$1" >&/dev/null) ||
            [[ $(command -v "$1" >&/dev/null) == "$1" ]] ||
            (which --skip-alias --skip-functions "$1" >&/dev/null)
    ) && (
        ($1 --help 2>&1 | grep -qm1 -- '--color') ||
            ($1 -h 2>&1 | grep -qm1 -- '--color')
    ); then
        return 0
    else
        return 1
    fi
}

###  _____           _                                      _     _   _            _       _     _
### |  ___|         (_)                                    | |   | | | |          (_)     | |   | |
### | |__ _ ____   ___ _ __ ___  _ __  _ __ ___   ___ _ __ | |_  | | | | __ _ _ __ _  __ _| |__ | | ___  ___
### |  __| '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __| | | | |/ _` | '__| |/ _` | '_ \| |/ _ \/ __|
### | |__| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_  \ \_/ / (_| | |  | | (_| | |_) | |  __/\__ \
### \____/_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|  \___/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1

## Adds .local/bin to the path
if [[ -d $HOME/.local/bin ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

## Picks a hostname variable to use all around
## Works on several places including adb shells and ssh
_HOSTNAME=$(hostname | sed 's/localhost//')
_e "getprop" && _HOSTNAME=${_HOSTNAME:-$(getprop "net.hostname")}
_e "getprop" && _HOSTNAME=${_HOSTNAME:-$(getprop "ro.product.device")}
_HOSTNAME=${_HOSTNAME:-"bielefeld"}
is_ssh && _HOSTNAME="${_HOSTNAME} [SSH]" && _ENV_COLOR='\[\e[01;93m\]'
_e getprop && _HOSTNAME="${_HOSTNAME} [ADB]" && _ENV_COLOR='\[\e[00;91m\]'

## GPG Signing TTY: required for GPG signing in git
GPG_TTY=$(tty)
export GPG_TTY

## This fixes a bug that happens when calling `sudo su USER`
## inside a SSH shell that keeps loginctl envvars making some commands not work.
## @see https://unix.stackexchange.com/questions/346841/why-does-sudo-i-not-set-xdg-runtime-dir-for-the-target-user
if [[ -z $XDG_RUNTIME_DIR && $(is_ssh) ]]; then
    export XDG_RUNTIME_DIR=/run/user/$UID
fi

## Sets default EDITOR environment variable
## If logged as root or in a ssh shell uses only term editors.
_e "nano" && export EDITOR="nano"
if [[ -n $DISPLAY && ! $EUID -eq 0 && ! $(is_ssh) ]]; then
    for editor in "subl3" "subl" "code" "gedit"; do
        _e "$editor" && export EDITOR=$editor
    done
fi

## Android shit
if [[ -d $ANDROID_NDK ]]; then
    export ANDROID_NDK_ROOT="$ANDROID_NDK"
    export ANDROID_NDK_HOME="$ANDROID_NDK"
fi

if [[ -d "/opt/android-sdk" ]]; then
    export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:="/opt/android-sdk"}
    export ANDROID_HOME=${ANDROID_HOME:=$ANDROID_SDK_ROOT}

    if [[ -d $ANDROID_HOME ]]; then
        # adds build tools (aapt, dexdump, etc)
        # only adds the highest version
        build_tools="$(find "$ANDROID_HOME/build-tools" -maxdepth 1 -type d | sort --numeric-sort --reverse | head -n1)"
        if [[ -d "$build_tools" ]]; then
            export PATH="$PATH:$build_tools"
        fi

        if [[ -d "$ANDROID_HOME/platform-tools" ]]; then
            export PATH="${PATH}:$ANDROID_HOME/platform-tools"
        fi
    fi
fi

### ______           _       _____ _                        _   _   _ _     _
### | ___ \         | |     |  ___| |                      | | | | | (_)   | |
### | |_/ / __ _ ___| |__   | |__ | |_ ___ _ __ _ __   __ _| | | |_| |_ ___| |_ ___  _ __ _   _
### | ___ \/ _` / __| '_ \  |  __|| __/ _ \ '__| '_ \ / _` | | |  _  | / __| __/ _ \| '__| | | |
### | |_/ / (_| \__ \ | | | | |___| ||  __/ |  | | | | (_| | | | | | | \__ \ || (_) | |  | |_| |
### \____/ \__,_|___/_| |_| \____/ \__\___|_|  |_| |_|\__,_|_| \_| |_/_|___/\__\___/|_|   \__, |
###                                                                                        __/ |
###                                                                                       |___/
# Change the file location because certain bash sessions truncate .bash_history file upon close:
export HISTFILE=$HOME/.bash_eternal_history
# Maximum number of entries on the current session (nothing is infinite):
export HISTSIZE=5000000
# Maximum number of lines in HISTFILE (nothing is infinite).
export HISTFILESIZE=10000000
# Commands to ignore and skip saving
export HISTIGNORE="clear:exit:history:ls:gitl:gits"
# Ignores dupes and deletes old ones (latest doesn't work _quite_ properly, but does the trick)
export HISTCONTROL=ignoredups:erasedups
# Custom history time prefix format
export HISTTIMEFORMAT='[%F %T] '
# Writes multiline commands on the history as multiline entries
shopt -s cmdhist
shopt -s lithist
# Appends to history after every command instead of only after the shell session ends.
shopt -s histappend
# WIP/FIXME: Erases history dups on EXIT
# function historymerge() {
#     history -n
#     history -w
#     history -c
#     history -r
# }
# trap historymerge EXIT

###   ___        _                                  _      _   _
###  / _ \      | |                                | |    | | (_)
### / /_\ \_   _| |_ ___   ___ ___  _ __ ___  _ __ | | ___| |_ _  ___  _ __
### |  _  | | | | __/ _ \ / __/ _ \| '_ ` _ \| '_ \| |/ _ \ __| |/ _ \| '_ \
### | | | | |_| | || (_) | (_| (_) | | | | | | |_) | |  __/ |_| | (_) | | | |
### \_| |_/\__,_|\__\___/ \___\___/|_| |_| |_| .__/|_|\___|\__|_|\___/|_| |_|
###                                          | |
###                                          |_|
## TIP: to create autocompletion for custom funcs without
##      writing our own completion function:
# 1. Type the command, and press <Tab> to autocomplete
# 2. Run `complete -p command`
# 3. The output is the hook that was used to complete it.
# 4. Change it accordingly to apply it to your function.
## Loads bash's system-wide installed completions
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi
## Loads gits completion file for our custom completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    # The STDERR redirection is to not print an annoying bug on
    # GCP VMs that make sed error out for some stupid reason and bad coding
    source /usr/share/bash-completion/completions/git #2>/dev/null
fi
## Node autocompletions
if _e node; then
    source <(node --completion-bash)
fi

###  _   _ _   _ _
### | | | | | (_) |
### | | | | |_ _| |___
### | | | | __| | / __|
### | |_| | |_| | \__ \
###  \___/ \__|_|_|___/

#  +-+-+-+-+-+-+-+-+-+
#  |u|r|l|d|e|c|o|d|e|
#  +-+-+-+-+-+-+-+-+-+
function urldecode() {
    : "${*//+/ }"
    echo -e "${_//%/\\x}"
}

##  +-+-+-+-+-+-+-+-+-+-+-+-+-+
##  |s|e|l|e|c|t|_|o|p|t|i|o|n|
##  +-+-+-+-+-+-+-+-+-+-+-+-+-+
# Amazing bash-only menu selector
# Taken from http://tinyurl.com/y5vgfon7
# Further edits by @emi
function select_option() {
    # This returns 255 when SIGINT (Ctrl+C) is pressed
    ESC=$(printf "\033")
    cursor_blink_on() { printf "${ESC}[?25h"; }
    cursor_blink_off() { printf "${ESC}[?25l"; }
    cursor_to() { printf "${ESC}[$1;${2:-1}H"; }
    print_option() { printf "   $1 "; }
    print_selected() { printf "  ${ESC}[7m $1 ${ESC}[27m"; }
    get_cursor_row() {
        IFS=';' read -sdR -p $'\E[6n' ROW COL
        echo ${ROW#*\[}
    }
    key_input() {
        read -s -n3 key 2>/dev/null >&2
        if [[ $key == $ESC\[A ]]; then echo up; fi
        if [[ $key == $ESC\[B ]]; then echo down; fi
        if [[ $key == "" ]]; then echo enter; fi
    }
    for opt; do printf "\n"; done
    local lastrow=$(get_cursor_row)
    local startrow=$(($lastrow - $#))
    trap "cursor_blink_on; stty echo; printf '\n'; trap - SIGINT; return 255;" SIGINT
    cursor_blink_off
    local selected=0
    while true; do
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then print_selected "$opt"; else print_option "$opt"; fi
            ((idx++))
        done
        case $(key_input) in
        enter)
            break
            ;;
        up)
            ((selected--))
            if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
            ;;
        down)
            ((selected++))
            if [ $selected -ge $# ]; then selected=0; fi
            ;;
        esac
    done
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on
    trap - SIGINT
    return $selected
}

##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
##  |f|o|r|m|a|t|_|d|u|r|a|t|i|o|n|
##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## Formats seconds into more pretty H:M:S
## Stolen from: https://bit.ly/3nJQFwp
function format_duration() {
    T=$1
    S=$((T % 60))
    M=$((T / 60 % 60))
    H=$((T / 60 / 60 % 24))
    D=$((T / 60 / 60 / 24))
    [[ $D -gt 0 ]] && printf '%dd%dh' $D $H ||
        ([[ $H -gt 0 ]] && printf '%dh%dm' $H $M) ||
        ([[ $M -gt 0 ]] && printf '%dm%ds' $M $S) ||
        printf "%ds" $S
}

## +-+-+-+-+-+-+-+-+-+-+-+-+-+
## |b|a|s|h|_|p|r|o|f|i|l|e|r|
## +-+-+-+-+-+-+-+-+-+-+-+-+-+
profile_command() {
    if [[ $# -eq 0 || $# -ne 2 ]]; then
        echo "Usage: profile_command number_of_times 'command [args]'"
        echo -e "\nExample: profile_command 10 'sleep 1'"
        echo -e "This will run 'sleep 1' 10 times and print statistics about the performance."
        echo -e "Note: you must quote the command to be profiled. Bash builtins aren't supported."
        return 1
    fi
    local high_precision=false
    local date_cmd='date +%s'
    if _e bc && [[ $(date '+%N') != "+%N" ]]; then
        high_precision=true
        date_cmd='date +%s.%N'
    fi

    start_time=0
    end_time=0
    start_time="$($date_cmd)"
    for round in $(seq 1 "$1"); do
        $2 >/dev/null
        echo -en "\rRound $round/$1"
    done
    end_time="$($date_cmd)"
    local elapsed_time
    local time_per_round
    if $high_precision; then
        elapsed_time=$(echo "scale=13; $end_time-$start_time" | bc -l)
        time_per_round=$(echo "scale=8; ${elapsed_time} * 1000 / ${1}" | bc -l)
    else
        elapsed_time=$((end_time - start_time))
        time_per_round=$((elapsed_time / $1))
    fi

    echo -e "\nTotal time:\t$elapsed_time seconds.\nTime per round:\t$time_per_round ms."
}

##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
##  |g|e|t|_|t|r|u|n|c|a|t|e|d|_|p|w|d|
##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## Returns a truncated $PWD depending on window width
function _get_truncated_pwd() {
    local tilde="~"
    local newPWD="${PWD/#${HOME}/${tilde}}"
    local pwdmaxlen="$((${COLUMNS:-80} / 4))"
    [[ "${#newPWD}" -gt "${pwdmaxlen}" ]] && newPWD="…${newPWD:3-$pwdmaxlen}"
    echo -n "${newPWD}"
}

##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
##  |d|i|s|a|b|l|e|_|v|e|n|v|_|p|r|o|m|p|t|
##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## Disables the native embedded venv prompt so we can make our own
export VIRTUAL_ENV_DISABLE_PROMPT=0
function _virtualenv_info() {
    [[ -n "$VIRTUAL_ENV" ]] && echo "${VIRTUAL_ENV##*/}"
}

#  _____       _
# /  __ \     | |
# | /  \/ ___ | | ___  _ __ ___
# | |    / _ \| |/ _ \| '__/ __|
# | \__/\ (_) | | (_) | |  \__ \
#  \____/\___/|_|\___/|_|  |___/
## Magic with `less` (like colors and other cool stuff)
export LESS="R-P ?c<- .?f%f:Standard input.  ?n:?eEND:?p%pj\%.. .?c%ccol . ?mFile %i of %m  .?xNext\ %x.%t   Press h for help"

## Magic with man pages (colors mainly)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

## Colors at file types when autocompleting and more
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -f $HOME/.dircolors ]]; then
        . <(dircolors -b $HOME/.dircolors)
    else
        . <(dircolors -b $HOME/.dircolors)
    fi
    _COLOR_ALWAYS_ARG='--color=always' # FIXME: makes no sense for this to be inside this block
fi

## Global colouriser used all around to make everything even gayer
if _e "grc"; then
    GRC='grc -es '
    alias colourify="$GRC -es"
    alias blkid='colourify blkid'
    alias configure='colourify ./configure'
    alias docker='colourify docker'
    alias docker-compose='colourify docker-compose'
    alias docker-machine='colourify docker-machine'
    alias efibootmgr='colourify efibootmgr'
    alias du='colourify du -h'
    alias free='colourify free'
    alias fdisk='colourify fdisk'
    alias findmnt='colourify findmnt'
    alias make='colourify make'
    alias gcc='colourify gcc'
    alias g++='colourify g++'
    alias id='colourify id'
    alias ip='colourify ip'
    alias iptables='colourify iptables'
    alias journalctl='colourify journalctl'
    alias kubectl='colourify kubectl'
    alias lsof='colourify lsof'
    alias lsblk='colourify lsblk'
    alias lspci='colourify lspci'
    alias netstat='colourify netstat'
    alias ping='colourify ping'
    alias traceroute='colourify traceroute'
    alias traceroute6='colourify traceroute6'
    alias dig='colourify dig'
    alias mount='colourify mount'
    alias ps='colourify ps'
    alias mtr='colourify mtr'
    alias semanage='colourify semanage'
    alias getsebool='colourify getsebool'
    alias ifconfig='colourify ifconfig'
    alias sockstat='colourify sockstat'
fi

###  _____  _____ _      ______         _
### |  _  ||  _  | |     |  ___|       | |
### | | | || | | | |     | |_ ___  __ _| |_ _   _ _ __ ___  ___
### | | | || | | | |     |  _/ _ \/ _` | __| | | | '__/ _ \/ __|
### \ \/' /\ \_/ / |____ | ||  __/ (_| | |_| |_| | | |  __/\__ \
###  \_/\_\ \___/\_____/ \_| \___|\__,_|\__|\__,_|_|  \___||___/

##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
##  |S|w|i|f|t| |H|i|s|t|o|r|y| |S|e|a|r|c|h|
##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
## Fancy way of quickly grepping the command history.
## An alternative to Ctrl+R that supports regex.
## Example:
##   h 'clone.*gitlab'
## Will show a list with all previous commands that match
## the regex 'clone.*gitlab'. The number prefixing each entry
## is the command history position, meaning that if you want to
## replay a particular entry with the number 4513, you can run:
##   !!4513
## You can also get context around a particular entry with:
##   h 4513
function h() {
    GET_NEARBY=0
    if [[ $1 =~ ^[0-9][0-9]*$ ]]; then
        GET_NEARBY=1
    fi
    # Workaround for the lack of
    # multidimensional arrays in bash.
    local results_cmds=()
    local results_nums=()
    local query="${@}"

    if [[ $GET_NEARBY == 1 ]]; then
        readarray -d '' grepped_history < <(history | \grep -ZEC30 "^$1 ")
    else
        readarray -d '' grepped_history < <(history | \grep -ZEC0 -- "$query")
    fi
    # echo $
    while read -r entry; do
        local number="${entry// */}"
        local datetime="${entry#*[}"
        datetime="${datetime%] *}"
        local cmd="${entry##$number*$datetime] }"
        # # Strips repeated results
        if [[ $GET_NEARBY == 0 ]]; then
            if [[ ! "${results_cmds[*]}" =~ $cmd ]]; then
                results_cmds+=("$cmd")
                results_nums+=("$number")
            fi
        else
            results_cmds+=("$cmd")
            results_nums+=("$number")
        fi
    done < <(echo "${grepped_history[@]}")

    num=0
    for r in "${!results_cmds[@]}"; do
        if [[ $GET_NEARBY == 1 ]]; then
            cmd="${results_cmds[$r]}"
            if [[ "${results_nums[$r]}" -eq $1 ]]; then
                cmd=$'\e[33m'"${results_cmds[$r]}"$'\e[00m'
            fi
        else
            cmd="$(echo "${results_cmds[$r]}" | sed "s/\($query\)/"$'\e[33m'"\1"$'\e[00m'"/g")"
            if [[ $cmd == "" ]]; then
                cmd="${results_cmds[$r]}"
            fi
        fi
        # if [[ "${results_nums[$r]}" -gt "$((num+1))" ]]; then
        #     printf "\e[01;95m============\e[00m\n"
        # fi
        num=${results_nums[$r]}
        line="\e[01;96m${results_nums[$r]} \e[00m$cmd\e[00m"
        printf "$line\n"
    done
    printf "\e[01;95m============\e[00m\n"
}

##  +-+-+-+-+ +-+-+-+-+-+-+-+
##  |E|a|s|y| |E|x|t|r|a|c|t|
##  +-+-+-+-+ +-+-+-+-+-+-+-+
## Extracts compressed and archived files of any type
## without having to remember every single fucking argument
## for every single fucking compressed file extension
function extract() {
    for n in "$@"; do
        if [ -f "$n" ]; then
            case "${n%,}" in
            *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
                tar xvf "$n"
                ;;
            *.lzma) unlzma ./"$n" ;;
            *.bz2) bunzip2 ./"$n" ;;
            *.cbr | *.rar) unrar x -ad ./"$n" ;;
            *.gz) gunzip ./"$n" ;;
            *.cbz | *.epub | *.zip) unzip ./"$n" ;;
            *.z) uncompress ./"$n" ;;
            *.7z | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.dmg | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar)
                7z x ./"$n"
                ;;
            *.xz) unxz ./"$n" ;;
            *.exe) cabextract ./"$n" ;;
            *.cpio) cpio -id <./"$n" ;;
            *.cba | *.ace) unace x ./"$n" ;;
            *)
                echo "extract: '$n' - unknown archive method"
                return 1
                ;;
            esac
        else
            echo "'$n' - file does not exist"
            return 1
        fi
    done
}

##  +-+-+-+-+-+-+-+
##  |m|a|g|i|c|C|D|
##  +-+-+-+-+-+-+-+
## Searches for directories recursively and cds into them
## Usage:
##   alias ALIAS_NAME='_magicCD DIR_DEPTH BASE_DIR
## Where DIR_DEPTH is how many nested directories from
## within BASE_DIR to recursively search into.
## Author: emi~
##
## Example:
## Suppose you have this structure:
## - $HOME/Coding/
##   - Projects/
##       - project_1/
##       - project_2/
##       - foo/
##   - Personal/
##      - secret_self_bot/
##      - wip_project/
##
## If you add to this file,
##   alias cdp='_magicCD 2 $HOME/Coding/'
## then if you run,
## cdp: will send you to $HOME/Coding/
## cdp proj: will show you a selector with all the dirs containing 'proj',
##           i.e.: $HOME/Coding/Projects/project_1 and 2 and wip_project from Personal
## cdp wip: will directly send you to the only dir containing 'wip'
##           i.e.: $HOME/Coding/Projects/wip_project
function _magicCD() {
    if [[ ! -d "$2" && ! "$1" -ge 2 ]]; then
        echo "Error in the syntax."
        return 1
    fi

    __MAGIC_CD_DIR="${2}"
    __DEPTH="${1}"
    shift
    shift

    # If the search query is exactly the dir name
    # then just cd
    if [[ -d "${1}" ]]; then
        cd "${1}"
        return
    elif [[ -d "${__MAGIC_CD_DIR}${1}" ]]; then
        cd "${__MAGIC_CD_DIR}${1}"
        return
    fi

    # Black magic ;)
    # results=()
    # while IFS=  read -r -d $'\0'; do
    #     results+=("$REPLY")
    # done < <(find "${__MAGIC_CD_DIR}" -depth  -maxdepth 2 -type d -iname \*${*}\* -print0)

    # Neat black magic (bash 4.4 only)
    readarray -d '' results < <(find -L ${__MAGIC_CD_DIR} -maxdepth ${__DEPTH} -path "*node_modules*" -prune -o -type d -iname \*${*}\* -print0)

    if [[ ${#results[@]} -eq 1 ]]; then
        # If there's an unique result for the argument, cd into it:
        cd "${results[0]}"
    elif [[ ${#results[@]} -eq 0 || ${#results[@]} -gt 20 ]]; then
        cd "${__MAGIC_CD_DIR}"
    else
        # Let the user choose
        select_option "${results[@]}"
        cd "${results[$?]}"
    fi
}

##  +-+-+-+-+-+-+
##  |F|I|N|D|I|R|
##  +-+-+-+-+-+-+
## Finds directories recursively, and shows select_option
## afterwards if less than 20 results.
function findir() {
    readarray -d '' results < <(find . -path "*node_modules*" -prune -o -type d -iname \*"${1}"\* -print0 2>/dev/null)

    if [[ ${#results[@]} -eq 1 ]]; then
        # If there's an unique result for the argument, cd into it:
        cd "${results[0]}"
    elif [[ ${#results[@]} -eq 0 || ${#results[@]} -gt 20 ]]; then
        printf '%s\n' "${results[@]}"
    else
        # Let the user choose
        select_option "${results[@]}"
        cd "${results[$?]}"
    fi
}

##  +-+-+-+-+-+-+
##  |c|d|c|o|o|l|
##  +-+-+-+-+-+-+
## This shows a selector to quickly change
## cd into commonly used, hard-to-type directories,
## changing to a su prompt if the user doesn't have
## reading permissions as well.
function cdcool() {
    # Filters the array in case there's an arg
    if [[ -n "$1" ]]; then
        for index in "${!cool_places[@]}"; do
            if [[ ! ${cool_places[$index]} =~ $1 ]]; then
                unset -v 'cool_places[$index]'
            fi
        done
    fi

    # Let the user choose
    if [[ ${#cool_places[@]} -eq 1 ]]; then
        selected_index=0
    else
        select_option "${cool_places[@]}"
        selected_index="$?"
    fi

    final_path="${cool_places[$selected_index]/#\$HOME/$HOME}"

    if [[ ! -d "$final_path" ]]; then
        echo "The selected path does not exist. Fix your script." && return 1
    elif ! test -r "$final_path"; then
        echo -n "No read permissions for $final_path! "
        sudo su root sh -c "cd $final_path; bash" # don't ask, just don't.
    else
        cd "$final_path" || return 1
    fi
}
## List of places to show when using 'cdcool [arg]'
cool_places=(
    "$HOME/.local/share/gnome-shell/extensions"
    "$HOME/.local/share/nautilus/scripts"
    "$HOME/.local/share/applications"
    "$HOME/.config/systemd/user/"
    "/etc/systemd/user/"
    "/var/lib/docker/volumes"
    "/usr/share/bash-completion/completions"
)

###   ___  _ _                                        _    _____                     _     _
###  / _ \| (_)                                      | |  |  _  |                   (_)   | |
### / /_\ \ |_  __ _ ___  ___  ___     __ _ _ __   __| |  | | | |_   _____ _ __ _ __ _  __| | ___  ___
### |  _  | | |/ _` / __|/ _ \/ __|   / _` | '_ \ / _` |  | | | \ \ / / _ \ '__| '__| |/ _` |/ _ \/ __|
### | | | | | | (_| \__ \  __/\__ \  | (_| | | | | (_| |  \ \_/ /\ V /  __/ |  | |  | | (_| |  __/\__ \
### \_| |_/_|_|\__,_|___/\___||___/   \__,_|_| |_|\__,_|   \___/  \_/ \___|_|  |_|  |_|\__,_|\___||___/
## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '
## Navigation
alias ls="${GRC}ls -ltr --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"
alias g="xdg-open"

## Uses system python as pip
alias pip='python -m pip'

## Node
alias node='node --experimental-modules  --experimental-repl-await  --experimental-vm-modules  --experimental-worker --experimental-import-meta-resolve'

## True screen clearing
function clear() {
    echo -en "\033c"
}

## use bat instead of cat if available
function cat() {
    if [[ -t 0 ]] && [[ $# == 1 ]] && _e bat && bat -L | grep -qm1 "[,:]${1##*.}($|,)"; then
        command bat "$@"
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
## Watch defaults
if watch --help 2>/dev/null | grep -qm1 color; then
    alias watch="watch --color -n 0.5"
else
    alias watch="watch -n 0.5"
fi
## Colors on DF
alias df="${GRC}df -H"
## Makes dd pretty and with progress bar
alias dd="dd status=progress oflag=sync"
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

##  +-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+
##  |a|n|d|r|o|i|d| |d|e|b|u|g| |b|r|i|d|g|e|
##  +-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+
if _e "adb"; then
    _adb_devices=()
    function _adb_get_devices() {
        # this is how they actually do it officially lol:
        # _adb_devices=$(command adb devices 2> /dev/null | grep -v "List of devices" | awk '{ print $1 }');
        # this is more robust and works with offline devices sorry
        readarray -t _adb_devices < <(command adb devices -l 2>/dev/null | sed -E $'1d;$d;/.+offline.+/d' | awk '{print $1}')
    }
    function _adb_get_target_device() {
        # if there are multiple devices connected,
        # show a selector using select_option
        # otherwise, just return the first device
        if [[ ${#_adb_devices[@]} -gt 1 ]]; then
            echo "Multiple devices connected, please select one:"
            select_option "${_adb_devices[@]}"
            return $?
        else
            echo "${_adb_devices[0]}"
        fi
    }
    function adb() {
        local _ADB_CMDS_TO_SHOW_SELECTOR=("push" "pull" "shell" "install" "install-multiple" "install-multi-package" "uninstall"
            "bugreport" "logcat" "lolcat" "sideload" "usb" "tcpip" "root" "unroot" "reboot" "remount")
        if [[ $1 == "devices" && ($# == 1) ]] && _e grcat && [[ -f $HOME/.grc/conf.efibootmgr ]]; then
            while read -r a b c; do
                [[ $a != "" || $b != "" || $c != "" ]] && printf "%-7s %-28s%s\n" "$a" "$b" "$c"
            done < <(command adb devices -l | sed '1d;$d' |
                sed -E $'s/(.+) +offline .+device:(.+) transport_id:([0-9]+)/TID=\\3\tserial=\\1\tproduct=\\2\E[31;01m OFFLINE\E[00m/' |
                sed -E $'s/(.+) +unauthorized +transport_id:([0-9]+)/TID=\\2\tserial=\\1\t\E[31;01mUNAUTHORIZED\E[00m/' |
                sed -E "s/([^ ]+) +device .+device:(.+) transport_id:([0-9]+)/TID=\3\tserial=\1\tproduct=\2/") | grcat "$HOME/.grc/conf.efibootmgr"
        else
            _adb_get_devices
            # if there is no device specified
            # and the command is in the list of commands to show a selector for
            if [[ ($1 != "-s" && $1 != "-d" && $1 != "-e" && $1 != "-t") && " ${_ADB_CMDS_TO_SHOW_SELECTOR[*]} " =~ " $1 " && ${#_adb_devices[@]} -gt 1 ]]; then
                # if there are multiple devices connected
                _adb_get_target_device
                local ret=$?
                if [[ ${_adb_devices[$ret]} != "" ]]; then
                    command adb -s "${_adb_devices[$ret]}" "${@:1}"
                elif [[ $ret -eq 255 ]]; then
                    echo "Maybe next time."
                else
                    command adb "${@}"
                fi
            else
                command adb "${@}"
            fi
        fi
    }
    alias logcat=$'adb logcat -b all -v color,usec,uid -T "$(date \'+%F %T.000\' --date=\'5 minutes ago\')"'
    complete -F _complete_alias logcat
fi

##  +-+-+-+-+-+-+-+-+-+-+
##  |j|o|u|r|n|a|l|c|t|l|
##  +-+-+-+-+-+-+-+-+-+-+
function _systemctl_exists_user() {
    service="${1//.service/}"
    [ "$(systemctl --user list-unit-files "${service}.service" | wc -l)" -gt 3 ] &&
        [ "$(systemctl list-unit-files "${service}.service" | wc -l)" -eq 3 ]
}

if _e "journalctl"; then
    alias je='journalctl -efn 50 -o short --no-hostname'
    alias jb='journalctl -b -o short --no-hostname'
    function st() {
        if _systemctl_exists_user "${1}"; then
            journalctl --output cat -lxef _SYSTEMD_USER_UNIT="${1}"
        else
            journalctl --output cat -lxef _SYSTEMD_UNIT="${1}"
        fi
    }
    function _complete_journalctl() {
        local cur
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(compgen -W "$(journalctl -F _SYSTEMD_UNIT) $(journalctl -F _SYSTEMD_USER_UNIT)" -- $cur))
    }
    complete -F _complete_journalctl st
    complete -F _complete_alias je jb
fi

##  +-+-+-+-+-+-+-+-+-+
##  |s|y|s|t|e|m|c|t|l|
##  +-+-+-+-+-+-+-+-+-+
if _e "systemctl"; then
    function _scomps() {
        local cur
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        if [[ $1 == "loaded" ]]; then
            user_units=$(systemctl --user list-unit-files --type socket,service,timer --all | grep -E '(service|socket|timer)' | awk '{print $1}')
            system_units=$(systemctl list-unit-files --type socket,service,timer --all | grep -E '(service|socket|timer)' | awk '{print $1}')
        elif [[ $1 == "enabled" || $1 == "disabled" ]]; then
            user_units=$(systemctl --user list-unit-files --type socket,service,timer --all --state=$1 | grep -E '(service|socket|timer)' | awk '{print $1}')
            system_units=$(systemctl list-unit-files --type socket,service,timer --all --state=$1 | grep -E '(service|socket|timer)' | awk '{print $1}')
        else
            user_units=$(systemctl --user list-units --type socket,service,timer --state=$1 | grep -E '(service|socket|timer).*loaded' | awk '{print $1}')
            system_units=$(systemctl list-units --type socket,service,timer --state=$1 | grep -E '(service|socket|timer).*loaded' | awk '{print $1}')
        fi
        # user_units
        COMPREPLY=($(compgen -W "$user_units $system_units" -- $cur))
    }
    function _sstart() {
        _scomps inactive
    }
    function _sstop() {
        _scomps running
    }
    function _srestart() {
        _scomps loaded
    }
    function _sstatus() {
        _scomps loaded
    }
    function _senable() {
        _scomps disabled
    }
    function _sdisable() {
        _scomps enabled
    }

    sstart() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user start "${1}"
        else
            systemctl start "${1}"
        fi
    }
    complete -F _sstart sstart
    sstop() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user stop "${1}"
        else
            systemctl stop "${1}"
        fi
    }
    complete -F _sstop sstop
    srestart() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user restart "${1}"
        else
            systemctl restart "${1}"
        fi
    }
    complete -F _srestart srestart
    sstatus() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user status "${1}"
        else
            systemctl status "${1}"
        fi
    }
    complete -F _sstatus sstatus
    senable() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user enable "${1}"
        else
            systemctl enable "${1}"
        fi
    }
    complete -F _senable senable
    sdisable() {
        if _systemctl_exists_user "${1}"; then
            systemctl --user disable "${1}"
        else
            systemctl disable "${1}"
        fi
    }
    complete -F _sdisable sdisable
fi

##  +-+-+-+-+-+-+-+-+-+-+
##  |p|a|c|m|a|n|/|y|a|y|
##  +-+-+-+-+-+-+-+-+-+-+
if _e "pacman"; then
    if _e "yay"; then
        function yayedit() {
            CURRDIR="$PWD"
            if ! yay -Ss "$1" | grep "aur/$1 " -qm 1; then
                echo "Package $1 does not exist."
                return
            fi
            echo "Will edit PKGBUILD of package $1"
            cd /tmp/yay/build/
            yay -G "$1"
            cd "$1"
            $EDITOR PKGBUILD
            echo "Press enter when done editing... Type 'n' and press enter if you don't want makepkg to overwrite changes in src!"
            read overwrite
            if [[ $overwrite == "n" ]]; then
                echo "Not overwriting src"
                makepkg -esi --skipchecksums
            else
                makepkg -si --skipchecksums
            fi

            cd "$CURRDIR"
        }
        # function _yay() {
        #     if [[ $# == 0 ]]; then
        #         # if running simply `yay`, then ask for packages to ignore
        #         command yay --noanswerupgrade -Syu
        #     fi
        #     command yay "$@"
        # }
        # alias yay="_yay"
    fi
    alias pacman="pacman "
    alias pacs="sudo pacman -S --needed --asdeps"
    alias pacr="sudo pacman -R --recursive --unneeded --cascade"
    alias pacss="pacman -Ss"
    alias paci="pacman -Qi"
    alias pacl="pacman -Ql"
    alias paccache_safedelete="sudo paccache -r && sudo paccache -ruk1"
    complete -F _complete_alias pacs
    complete -F _complete_alias pacr
    complete -F _complete_alias pacss
    complete -F _complete_alias paci
    complete -F _complete_alias pacl
    complete -F _complete_alias paccache_safedelete

    ## Pacman Awesome Updater
    function pacsyu() {
        echo -e "\e[01;93mUpdating pacman repositories...\e[00m"
        sudo pacman -Sy

        mkdir -p "$HOME/.pacman-updated"
        currentUpdatePkgs=$(\pacman -Qu --color never)
        previousUpdatePkgs=$(cat .pacman-updated/$(\ls -L .pacman-updated/ | tail -n1))
        if [[ "$currentUpdatePkgs" == "$previousUpdatePkgs" ]]; then
            echo -e "\e[00;92\nThis is the same list that was previously saved, not saving again.\e[00m"
        else
            echo -e "\e[01;93m\nSaving log of packages to upgrade...\e[00m"
            echo "$currentUpdatePkgs" >"$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)"
        fi

        echo -e "\e[01;91m\nUpdating pacman packages...\e[00m"
        sudo yay -Syu --noconfirm
    }

    ## NOT REQUIRED ANYMORE BECAUSE BTRFS
    # function pacman_rollback() {
    #     echo 'WARNING THIS IS A WIP. CHECK THE SOURCE FIRST AND RUN MANUALLY.'
    #     return 1
    #     if [[ -f $1 ]]; then
    #         while read line; do
    #             pkg=$(echo "$i" | sed 's/ -> .+//' | sed 's/ /-/')
    #             echo "Downgrading $pkg"
    #             sudo pacman --noconfirm --needed -U /var/cache/pacman/pkg/$pkg*
    #         done < <(cat $1)
    #     fi
    # }

    # Optimizes pacman stuff (TODO: does it?)
    alias pacfix='sudo pacman-optimize; sudo pacman -S $(pacman -Qkqn | sed -E "s/ .+$//" | uniq | xargs); paccache -k2 --min-mtime "60 days ago" -rv'
fi

#    ___ ___ _____
#   / __|_ _|_   _|
#  | (_ || |  | |
#   \___|___| |_|
if _e "git"; then
    # does not open editor when merging
    export GIT_MERGE_AUTOEDIT=no
    # alias gitl='git log --all --decorate=full --oneline'
    alias gitl="git log --graph --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"
    alias gitw="git log --no-merges --pretty=format:'------------> %C(bold red)%h%Creset -%C(bold yellow)%d%C(bold white) %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -p"
    alias gits='git status --show-stash --no-renames'
    # alias gitcam='git commit -a -m '

    function gitcam() {
        git commit -a -m "$*"
    }

    function gitm() {
        git commit --amend -m "$*"
    }

    function gitd() {
        local -A files

        readarray diffs < <(git diff --color --stat=60 HEAD | sed '$d; s/^ //')
        for line in "${diffs[@]}"; do
            key=${line// |*/}
            files[${key// /}]=$line
        done
        readarray status < <(git status --show-stash --no-renames | sed '/  (use..*)$/d')
        for line in "${status[@]}"; do
            key=${line//* /}
            if [[ $line =~ modified: ]]; then
                echo -en "\e[93m\tmodified: \e[01m${files[${key%?}]}\e[00m"
            elif [[ $line =~ deleted: ]]; then
                echo -en "\e[91m\tdeleted:  \e[01m${files[${key%?}]}\e[00m"
            elif [[ $line =~ new\ file: ]]; then
                echo -en "\e[92m\tnew file: \e[01m${files[${key%?}]}\e[00m"
            elif [[ $line =~ On\ branch ]]; then
                echo -en "${line//On branch/On branch\\e[01;94m}\e[00m"
            else
                echo -en "$line"
            fi
        done
    }

    function gitcleanbranches() {
        git fetch --prune
        if [[ $# == 1 ]]; then
            master="$1"
        else
            master="master"
        fi
        if ! git checkout $master 2>/dev/null; then
            echo "Pass the master branch name as argv[1]!"
            return
        fi
        for r in $(git for-each-ref refs/heads --format='%(refname:short)'); do
            if [[ "$(git merge-base $master "$r")" == "$(git rev-parse --verify "$r")" ]]; then
                if [ "$r" != "$master" ]; then
                    git branch --delete "$r"
                fi
            fi
        done
    }

    ## Super awesome automatic git pull
    # - Deletes all local branches that were merged and deleted from the remote.
    # - Makes local branches without remote counterparts track them in case it's possible.
    # - Updates/syncs all local branches with their remote counterpart, not only the current checked-out one (if possible, of course).
    # - Warns about local branches that are both ahead and behind the remote counterparts and require manual intervention, something that will hopefully happen much less often by using this.
    # - If you have unstaged or uncommited local changes, git won't make you commit or stash them before pulling and will update the branch properly if the changes don't conflict. If they do, it'll warn you.
    function _git_sync() {
        local bold="$(printf '\033')[1m"
        local fgre="$(printf '\033')[32m"
        local fblu="$(printf '\033')[34m"
        local fred="$(printf '\033')[31m"
        local fyel="$(printf '\033')[33m"
        local fvio="$(printf '\033')[35m"
        local end="$(printf '\033')[0m"

        REMOTES=$(git remote | xargs -n1 echo)
        CLB=$(git rev-parse --abbrev-ref HEAD)
        echo "$REMOTES" | while read REMOTE; do
            # for i in $(git for-each-ref --format='%(refname:short)' --no-merged=$REMOTE/HEAD refs/remotes/$REMOTE); do
            #     git switch --track $i
            # done
            git remote update $REMOTE --prune 2>&1 | \sed "s/ - \[deleted\]..*-> *$REMOTE\/\(..*\)/   ${fyel}Branch ${bold}\1${end}${fyel} was deleted from $REMOTE and will be pruned locally.${end}/"
            while read branch; do
                upstream=$(git rev-parse --abbrev-ref $branch@{upstream} 2>/dev/null)
                if [[ $? != 0 ]]; then
                    git branch --set-upstream-to=$REMOTE/$branch $branch >/dev/null 2>/dev/null
                    if [[ $? == 0 ]]; then
                        echo -e "   ${fvio}Branch ${bold}$branch${end}${fvio} was not tracking any remote branch! It was set to track ${bold}$REMOTE/$branch.${end}"
                    fi
                fi
            done < <(git for-each-ref --format='%(refname:short)' refs/heads/*)

            git remote show $REMOTE -n |
                awk '/merges with remote/{print $5" "$1}' |
                while read RB LB; do
                    ARB="refs/remotes/$REMOTE/$RB"
                    ALB="refs/heads/$LB"
                    NBEHIND=$(($(git rev-list --count $ALB..$ARB 2>/dev/null) + 0))
                    NAHEAD=$(($(git rev-list --count $ARB..$ALB 2>/dev/null) + 0))
                    if [ "$NBEHIND" -gt 0 ]; then
                        if [ "$NAHEAD" -gt 0 ]; then
                            echo -e "   ${fred}Branch ${bold}$LB${end}${fred} is ${bold}$NBEHIND${end}${fred} commit(s) behind and ${bold}$NAHEAD${end}${fred} commit(s) ahead of ${bold}$REMOTE/$RB${end}${fred}. Could not be fast-forwarded.${end}"
                        elif [ "$LB" = "$CLB" ]; then
                            git merge -q $ARB 2>/dev/null
                            if [[ $? == 0 ]]; then
                                echo -e "   ${fblu}Branch ${bold}$LB${end}${fblu} was ${bold}$NBEHIND${end}${fblu} commit(s) behind of ${bold}$REMOTE/$RB${end}${fblu}. Fast-forward merge.${end}"
                            else
                                if [[ $(git rev-parse --symbolic-full-name --abbrev-ref HEAD) == $LB ]]; then
                                    CURRENT="(currently checked out)"
                                fi
                                echo -e "   ${bold}${fred}Warning! Branch $LB${end}${fred} $CURRENT will conflict with new commits incoming from ${bold}$REMOTE/$RB${end}${fred}!${end}"
                                echo -e "   ${fred}You'll need to stash your changes before. Try \`${bold}git stash${end}${fred}\`, \`${bold}git merge${end}${fred}\`, then \`${bold}git stash pop${end}${fred}\`, and good luck!${end}"
                            fi
                        else
                            echo -e "   ${fgre}Branch ${bold}$LB${end}${fgre} was ${bold}$NBEHIND${end}${fgre} commit(s) behind of ${bold}$REMOTE/$RB${end}${fgre}. Resetting local branch to remote.${end}"
                            git branch -f $LB -t $ARB >/dev/null
                        fi
                    fi
                done
        done
    }

    function git() {
        if [[ $1 == "pull" && $# == 1 ]]; then
            shift
            _git_sync
        elif [[ $1 == "commit" && $2 == "--amend" && $# == 2 ]]; then
            command git commit --amend --no-edit
        else
            command git "$@"
        fi
    }

    function gitdelbranch() {
        # First command deletes local branch, but exits > 0 if not fully merged,
        # so the second command (which deletes the remote branch), will only run
        # if the first one suceeds, making it "safe".
        if [[ $(git symbolic-ref --short -q HEAD) == "${1}" ]]; then
            echo -e "You should leave the branch you're trying to delete first.}"
        else
            if ! git rev-parse --verify --quiet "${1}" && git ls-remote --quiet --exit-code --heads origin "${1}"; then
                echo -en "The local repository ${1} does not exist. Do you want to delete the remote one anyway? "
                read -p "[y/N] " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Deleting remote repo"
                    git push origin --delete "${1}"
                else
                    echo "Ok, bye!"
                fi
            elif git ls-remote --exit-code --heads origin "${1}"; then
                echo 'Deleting local repo'
                git branch --delete "${1}"
                echo 'Deleting remote repo'
                git push origin --delete "${1}"
            else
                echo "It seems that there is no branch called ${1} neither locally or in the remote"
            fi
        fi
    }

    # Autocomplete custom commands
    function _git_local_branches() {
        __gitcomp_direct "$(__git_heads)"
    }
    function _git_conventional_commits_prefixes() {
        __gitcomp "feat: fix: style: refactor: build: perf: ci: docs: test: chore: revert:"
    }
    __git_complete gitdelbranch _git_local_branches
    __git_complete gitcam _git_conventional_commits_prefixes

    # Overwrite git commit autocompletion
    _git_commit() {
        case "$prev" in
        -c | -C)
            __git_complete_refs
            return
            ;;
        -m)
            __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert: "
            return
            ;;
        esac

        case "$cur" in
        --cleanup=*)
            __gitcomp "default scissors strip verbatim whitespace
                " "" "${cur##--cleanup=}"
            return
            ;;
        --message=*)
            __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert:
                " "" "${cur##--message=}"
            return
            ;;
        --reuse-message=* | --reedit-message=* | \
            --fixup=* | --squash=*)
            __git_complete_refs --cur="${cur#*=}"
            return
            ;;
        --untracked-files=*)
            __gitcomp "$__git_untracked_file_modes" "" "${cur##--untracked-files=}"
            return
            ;;
        --*)
            __gitcomp_builtin commit
            return
            ;;
        esac

        if __git rev-parse --verify --quiet HEAD >/dev/null; then
            __git_complete_index_file "--committable"
        else
            # This is the first commit
            __git_complete_index_file "--cached"
        fi
    }
fi

###                                                                                                                      .         .
###  8888888 8888888888 8 8888        8 8 8888888888             8 888888888o   8 888888888o.      ,o888888o.           ,8.       ,8.          8 888888888o 8888888 8888888888
###        8 8888       8 8888        8 8 8888                   8 8888    `88. 8 8888    `88.  . 8888     `88.        ,888.     ,888.         8 8888    `88.     8 8888
###        8 8888       8 8888        8 8 8888                   8 8888     `88 8 8888     `88 ,8 8888       `8b      .`8888.   .`8888.        8 8888     `88     8 8888
###        8 8888       8 8888        8 8 8888                   8 8888     ,88 8 8888     ,88 88 8888        `8b    ,8.`8888. ,8.`8888.       8 8888     ,88     8 8888
###        8 8888       8 8888        8 8 888888888888           8 8888.   ,88' 8 8888.   ,88' 88 8888         88   ,8'8.`8888,8^8.`8888.      8 8888.   ,88'     8 8888
###        8 8888       8 8888        8 8 8888                   8 888888888P'  8 888888888P'  88 8888         88  ,8' `8.`8888' `8.`8888.     8 888888888P'      8 8888
###        8 8888       8 8888888888888 8 8888                   8 8888         8 8888`8b      88 8888        ,8P ,8'   `8.`88'   `8.`8888.    8 8888             8 8888
###        8 8888       8 8888        8 8 8888                   8 8888         8 8888 `8b.    `8 8888       ,8P ,8'     `8.`'     `8.`8888.   8 8888             8 8888
###        8 8888       8 8888        8 8 8888                   8 8888         8 8888   `8b.   ` 8888     ,88' ,8'       `8        `8.`8888.  8 8888             8 8888
###        8 8888       8 8888        8 8 888888888888           8 8888         8 8888     `88.    `8888888P'  ,8'         `         `8.`8888. 8 8888             8 8888

if [[ ! -s $HOME/.emishrc_last_check ]]; then
    [[ "$PS1" ]] && _changelog && date +%s >"$HOME/.emishrc_last_check"
else
    [[ "$PS1" ]] && _e "fortune" "cowthink" "lolcat" && [[ -s $HOME/.emishrc_last_check ]] && fortune -s -n 200 | PERL_BADLANG=0 cowthink | lolcat -F 0.1 -p 30 -S 1
fi

function _pre_command() {
    # Show the currently running command in the terminal title:
    # *see http://www.davidpashley.com/articles/xterm-titles-with-bash.html
    # *see https://gist.github.com/fly-away/751f32e7f6150419697d
    # *see https://goo.gl/xJMzHG

    # Instead of using $BASH_COMMAND, which doesn't deals with aliases,
    # uses an awesome tip by @zeroimpl. It's scary, touch it and it breaks!!!
    # *see https://goo.gl/2ZFDfM
    local this_command="$(HISTTIMEFORMAT= history 1 | \sed -E 's/^[ ]*[0-9]*[ ]*//')"
    case "$this_command" in
    *\033]0* | set_prompt* | echo* | printf* | cd* | ls)
        # The command is trying to set the title bar as well;
        # this is most likely the execution of $PROMPT_COMMAND.
        # In any case nested escapes confuse the terminal, so don't
        # output them.
        ;;
    *)
        # Changes the terminal title to the command that is going to be run
        # uses printf in case there are scapes characters on the command, which
        # would block the rendering.
        printf "\033]0;${this_command%% *}\007"
        ;;
    esac

    # Small fix that clears up all prompt colors, so we don't colorize any output by mistake
    echo -ne "\e[0m"
}

function _set_prompt() {
    # Must come first
    _last_command=$?

    # Saves on history after each command
    history -a
    # Read back from history file
    # history -n
    # Not working crazy shit that's supposed to actually erase previous dups (https://goo.gl/DXAcPO)
    # history -n; history -w; history -c; history -r;

    # Colors
    # TODO: refactor this legacy mess
    local Bold='\[\e[01m\]'
    local ResetBold='\[\e[22m\]'
    local Blue='\[\e[00;34m\]'
    local BlueLight='\[\e[00;94m\]'
    # local Bluelly='\[\e[38;5;31;1m\]'
    # local BluellyLight='\[\e[22;38;5;31;25m\]'

    local WhiteBold='\[\e[01;37m\]'
    local White='\[\e[22;37m\]'
    local Violet='\[\e[35m\]'
    local Magenta='\[\e[01;36m\]'
    local Red='\[\e[00;31m\]'
    local RedBold='\[\e[31;01m\]'
    local RedBoldLight='\[\e[91;01m\]'
    local Green='\[\e[00;32m\]'
    local GreenBold='\[\e[01;32m\]'
    local RedLight='\[\e[22;91m\]'
    local GreenLight='\[\e[01;92m\]'
    local YellowLight='\[\e[01;93m\]'
    local VioletLight='\[\e[95m\]'
    local White='\[\e[00;37m\]'
    local WhiteBoldLight='\[\e[01;97m\]'
    local WhiteBackground='\[\e[01;40m\]'
    local Yellow='\[\e[00;33m\]'
    local YellowBold='\[\e[01;33m\]'

    local Reset='\[\e[00m\]'
    # local FancyX='\342\234\227'
    # local Checkmark='\342\234\223'
    local FancyX='✘'
    local Checkmark='✔'

    # Prints  ---\n\n after previous command without spawning
    # a newline after it, so you can actually easily notice
    # if it's output has an EOF linebreak.
    PS1="$Yellow---$Reset\\n\\n"

    # Prints the error code
    if [[ $_last_command == 0 ]]; then
        PS1+="$GreenBold$Checkmark 000 "
    else
        PS1+="$RedBold$FancyX $(printf "%03d" $_last_command) "
    fi

    local __env_color="${_ENV_COLOR:-$White}"
    readarray -t repo_info <<<"$(git rev-parse --show-toplevel --show-prefix --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --short HEAD 2>/dev/null)"
    if [[ ${#repo_info[@]} -eq 7 ]]; then
        __env_color="${_ENV_COLOR:-$VioletLight}"
    fi

    PS1+="${__env_color}${Bold}\\u${ResetBold}@${_HOSTNAME}"

    ## Nicely shows you're in a python virtual environment
    if [[ -n $VIRTUAL_ENV ]]; then
        PS1+=" $Magenta(venv:$(_virtualenv_info))"
    fi

    ## Nicely shows you're in a git repository
    # TODO: @see: /usr/share/git/git-prompt.sh for more use cases and
    # more robust implementations.
    # FIXME: **this is slow**. depending on what you're doing, it might
    # hang when inside dirs of big projects (3gb+)
    if [[ ${#repo_info[@]} -eq 7 ]]; then
        local short_sha="${repo_info[6]}"
        branch_name=$(git symbolic-ref -q HEAD)
        branch_name=${branch_name##refs/heads/}
        branch_name=${branch_name:-$short_sha}

        PS1+=" ${__env_color}["

        # TODO: stop using git status here, it lags like fuck when
        #       lots of files are deleted
        local -r git_status=$(git status 2>&1) # TODO: still couldn't find what -r is about
        # see: https://github.com/koalaman/shellcheck/wiki/SC2155)
        if echo "${git_status}" | grep -qm1 'nothing to commit'; then
            if [[ $branch_name == "$short_sha" ]]; then
                PS1+="${WhiteBackground}${WhiteBold}• $branch_name•$Reset" # DETACHED HEAD
            else
                PS1+="$GreenLight✔ $branch_name•$Reset"
            fi
        elif echo "${git_status}" | grep -qm1 'Changes not staged'; then
            PS1+="$YellowBold→ $branch_name!$Reset"
        elif echo "${git_status}" | grep -qm1 'Changes to be committed'; then
            PS1+="$Violet→ $branch_name+$Reset"
        else
            PS1+="$BlueLight→ $branch_name*$Reset"
        fi
        if echo "${git_status}" | grep -qm1 'Untracked files'; then
            PS1+="$WhiteBoldLight?$Reset"
        fi

        # DIRECTORY DEBUGGING:
        # echo -e "repo_info[0]: \t${repo_info[0]}"         repo_info[0]: 	/home/emi/Coding/gnome-shell-wsmatrix
        # echo -e "repo_info[1]: \t${repo_info[1]}"         $(dirs +0): 	~/.local/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de/overview
        # echo -e "\$(dirs +0): \t$(dirs +0)"               repo_info[1]: 	wsmatrix@martin.zurowietz.de/overview/
        # echo -e "PWD:     \t${PWD}"                       PWD:     	    /home/emi/.local/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de/overview
        # echo -e "\$(pwd -L): \t$(pwd -L)"                 $(pwd -L): 	    /home/emi/.local/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de/overview
        # echo -e "\$(pwd -P): \t$(pwd -P)"                 $(pwd -P): 	    /home/emi/Coding/gnome-shell-wsmatrix/wsmatrix@martin.zurowietz.de/overview
        local relative_path="${repo_info[1]%\/}"
        local root_path
        root_path="$(dirs +0)"
        root_path="${root_path%"$relative_path"}"

        PS1+="$__env_color]$Reset $VioletLight$root_path$Bold$VioletLight$relative_path"
    else
        PS1+="$__env_color$Reset $BlueLight\\w"
    fi

    # Sets the prompt color according to
    # user (if logged in as root gets red)
    if [[ $(id -u) -eq 0 ]]; then
        PS1+="\\n${RedBoldLight}\\\$ ${RedLight}"
    else
        PS1+="\\n${YellowBold}\\\$ ${Yellow}"
    fi

    # Aligns stuff when you don't close quotes
    PS2=" | "

    # Debug (PS4)
    # ** Does not work if set -x is used outside an script :( **
    # It works wonderfully if you copy this to the script and apply set -x there though.
    #PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'

    ## Time right aligned
    # @see: https://superuser.com/questions/187455/right-align-part-of-prompt
    # Update: now with the time it took to run the previous command!
    printf -v PS1RHS "\e[0m[ \e[0;0;33m%(%b %d %H:%M:%S)T \e[0m]" -1 # -1 is current time

    # Strip ANSI commands before counting length
    # From: https://www.commandlinefu.com/commands/view/12043/remove-color-special-escape-ansi-codes-from-text-with-sed
    PS1RHS_stripped=$(echo "$PS1RHS" | sed -e "s,\x1B\[[0-9;]*[a-zA-Z],,g")

    # Reference: https://en.wikipedia.org/wiki/ANSI_escape_code
    local Save='\e[s' # Save cursor position
    local Rest='\e[u' # Restore cursor to save point

    # Save cursor position, jump to right hand edge, then go left N columns where
    # N is the length of the printable RHS string. Print the RHS string, then
    # return to the saved position and print the LHS prompt.

    # Note: "\[" and "\]" are used so that bash can calculate the number of
    # printed characters so that the prompt doesn't do strange things when
    # editing the entered text.

    PS1="\[${Save}\\n\e[${COLUMNS:-$(tput cols)}C\e[${#PS1RHS_stripped}D${PS1RHS}${Rest}\]${PS1}"

    # Changes the terminal window title to the current dir by default, truncating if too long.
    PS1="\033]0;$(_get_truncated_pwd)\007${PS1}"

    # Otherwise, if something is currently running, run _pre_command and change title to the app's name.
    trap '_pre_command' DEBUG
}

##  +-+-+-+-+-+-+ +-+-+-+
##  |v|t|e|.|s|h| |f|i|x|
##  +-+-+-+-+-+-+ +-+-+-+
# Fixes a bug (http://tinyurl.com/ohy3kmb) where spawning a new tab or window in gnome-terminal
# does not keep the current PWD, and defaults back to HOME (http://tinyurl.com/y7yknu3r).
# vte.sh replaces your PROMPT_COMMAND, so just source it and add it's function '__vte_prompt_command'
# to the end of your own PROMPT_COMMAND.
if [[ -n $VTE_VERSION && -f /etc/profile.d/vte.sh ]]; then
    source /etc/profile.d/vte.sh
    PROMPT_COMMAND='_set_prompt; __vte_prompt_command'
else
    PROMPT_COMMAND='_set_prompt'
fi

##  +-+-+-+-+-+-+
##  |c|u|s|t|o|m|
##  +-+-+-+-+-+-+
if [[ -f "$HOME/.bash_custom" ]]; then
    source "$HOME/.bash_custom"
fi
