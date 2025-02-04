#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155
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
export _RCVERSION=34
export _DATE="Jan 31st, 2025"
function _changelog() {
    local a=$'\e[36;03m'       # cyan
    local r=$'\e[00m'          # reset
    local n=$'\e[07m'          # inverted bg
    local b=$'\e[1m'           # bold
    local y=$'\e[33;01m'       # yellow
    local i=$'\e[00m\e[96;03m' # emphasis
    local g=$'\e[32;01m'       # green
    local c=$'\e[97m'          # code

    echo "${g}emi's .bashrc${r}
${y}Changelog 34 ($_DATE)${r}" | sed -e :a -e "s/^.\{1,$(($(tput cols) + 10))\}$/ & /;ta"
    echo -e "${n}This update is all about speed. Because, let's be honest, it was getting slow.${r}

  ${r}- ${b}The ${c}git${r}${b} prompt got a major overhaul.${r}
    ${a}It's faster now. A lot faster. But it might look a bit weird at first.${r}
    ${a}Yes, it might take you a second to get used to, but you’ll thank me later.${r}

  ${r}- ${b}Python environments now show up in the prompt.${r}
    ${a}If you're using ${c}pyenv${r}${a} or a virtualenv, you'll actually know about it now.${r}
    ${a}No more running ${c}python -V${r}${a} every five minutes to check if you're in the right version.${r}

  ${r}- ${b}Simple ${c}cat${r}${b} now just uses ${c}bat${r}${b}, but without paging.${r}
    ${a}You get syntax highlighting and everything, but you'll be able to copy and paste it.${r}

  ${r}- ${b}The auto-installer now warns you if ${c}.bashrc${r}${b} isn't sourced.${r}
    ${a}Because if you're not sourcing your ${c}.bashrc${r}${a}, you’re probably also the kind of person who ignores seatbelt warnings.${r}

  ${r}- ${b}Massive performance improvements across the board.${r}
    ${a}The hostname detection is snappier, the terminal title updates are smarter, and unnecessary checks have been nuked.${r}

  ${y}Tip: Use ${c}profile_command${r}${y} to measure how slow something is.${r}
  ${y}Run something like ${c}profile_command 1000 'ls'${r}${y} to see how long it actually takes.${r}
  "
}


###################
# CHAT GPT PROMPT #
###################
# Below there's a diff of changes for this .bashrc version release:
# DIFF:

# END DIFF
# You can see an example showcasing most available colors and text modifiers below:
# COLORS:
#     local a=$'\e[37;03m'       # cyan
#     local r=$'\e[00m'          # reset
#     local b=$'\e[1m'           # bold
#     local y=$'\e[33;01m'       # yellow
#     local i=$'\e[00m\e[96;03m' # emphasis
#     local g=$'\e[32;01m'       # green
#     local c=$'\e[97;03m'       # code
# END COLORS

# Using the diff, return a sound list of changes for the changelog of this version. Finally, pick your favorite change and add a tip at the bottom.
# Here's an example of how a response should look like:

# EXAMPLE:
#   ${r}- A new directory ${b}${c}/var/cache/pacman/pkg/${r}${b} was added to ${c}cdcool${r}${b}. ${a}Check tips below!${r}
#   ${r}${b}- Added a new function called ${c}pipi${r}.
#     It's a smart pip package installer which automatically adds installed packages to ${c}requirements.txt${r}${b} along with their versions.${r}
#   ${r}${b}- The ${c}journalctl${r}${b} aliases ${c}je${r}${b} and ${c}jb${r}${b}, were updated.${r}
#     The ${c}je${r} alias now displays the most recent 100 log entries, and the ${c}jb${r} alias has had the ${c}-e${r} flag added to display the last part of the logs.${r}
#   ${r}${b}- The git status display function ${c}gits${r}${b} was ${a}refactored${r}.
#     It now color codes the git status output according to the type of changes made to the git repository.${r}
#   ${r}${b}- The ${c}gitd${r}${b} alias was introduced${r} to show a more compact and informative git diff.
#   ${r}- New git configurations were added to improve your git experience.

#   ${i}Tip: try using MagicCD's commands, ${c}cdcool${r}${i} and ${c}cdX${r}${i} to quickly jump to important directories:${r}
#    - Edit your ${c}~/.bash_custom${r} file and add aliases like this:
#      ${c}alias cdc='_magicCD 2 $HOME/Coding/'${r}
#   ${i}This will present a menu with all subdirectories in $HOME/Coding/ that include the sequence ${c}scr${r}:${r}
#    $ ${c}cdc scri${r}
#    ${r}- /home/emi/Coding/pop-shell/scripts
#    ${n}- /home/emi/Coding/w3af/scripts${r}
#    - /home/emi/Coding/Scripts
#    - /home/emi/Coding/magenta-studio/scripts
#    - /home/emi/Coding/Mobile-Security-Framework-MobSF/scripts${r}
#   ${i}Select with ${b}UP/DOWN${r} ${i}keys and press ${b}ENTER${r}${i} to quickly navigate there.
# END EXAMPLE

# Do not return changes that aren't useful for a "final user", like if I updated the version and it shows in the diff above, it's not necessary to tell the final user of my script, as it's obvious. Here are examples of bad changes:
# BLACKLIST:
#   ${b}${a}- Incremented ${c}.bashrc${r}${a} version with ${c}_RCVERSION${r}${a}. This represents a new version of the .bashrc file to account for these changes.${r}
# END BLACKLIST

# Now return the text but for the changes in the DIFF above. Use the colors from and usage from the example to figure out how to use modifiers. Keep it pretty.
# RESPONSE:

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

declare -A IS_SSH_CACHE

function is_ssh() {
    local p=${1:-$PPID}

    if [[ -n ${IS_SSH_CACHE[$p]} ]]; then
        return "${IS_SSH_CACHE[$p]}"
    fi

    if [[ ! -f /proc/1/stat ]]; then
        IS_SSH_CACHE[$p]=1
        return 1
    fi

    read -r pid name x ppid y < <(cat "/proc/$p/stat")
    # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p)

    if [[ "$name" =~ sshd ]]; then
        IS_SSH_CACHE[$p]=0
        return 0
    fi

    if [[ "$ppid" -le 1 ]]; then
        IS_SSH_CACHE[$p]=1
        return 1
    fi

    is_ssh "$ppid"
    local result=$?
    IS_SSH_CACHE[$p]=$result
    return $result
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

# Check if the directories exist and add them to the PATH if they do
for dir in "$HOME/.local/bin" "$HOME/.yarn/bin" "$HOME/.bin" "$HOME/.cargo/bin"; do
    if [[ -d $dir ]]; then
        export PATH="$PATH:$dir"
    fi
done


## Picks a hostname variable to use all around
## Works on several places including adb shells and ssh
_ENV_COLOR='\[\e[22;37m\]'
_HOSTNAME=$(hostname)
if _e "getprop"; then
    # ADB shells
    _HOSTNAME=${_HOSTNAME:-$(getprop "net.hostname")}
    _HOSTNAME=${_HOSTNAME:-$(getprop "ro.product.device")}

    if [[ -n "$_HOSTNAME" ]]; then
        _HOSTNAME+=" [ADB]"
        _ENV_COLOR='\[\e[00;91m\]'
    fi
elif [[ -n "$_HOSTNAME" ]] && is_ssh; then
    # SSH shells
    _HOSTNAME+=" [SSH]"
    _ENV_COLOR='\[\e[01;93m\]'
fi

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
        echo -e "Note: you must quote the command to be profiled, it must print properly when echoing."
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
    if is_ssh; then
        echo -n "[SSH] ${newPWD}"
    else
        echo -n "${newPWD}"
    fi
}

#  _____       _
# /  __ \     | |
# | /  \/ ___ | | ___  _ __ ___
# | |    / _ \| |/ _ \| '__/ __|
# | \__/\ (_) | | (_) | |  \__ \
#  \____/\___/|_|\___/|_|  |___/
__Bold='\[\e[01m\]'
__ResetBold='\[\e[22m\]'
__Blue='\[\e[00;34m\]'
__BlueLight='\[\e[00;94m\]'
__Bluelly='\[\e[38;5;31;1m\]'
__BluellyLight='\[\e[22;38;5;31;25m\]'
__WhiteBold='\[\e[01;37m\]'
__White='\[\e[22;37m\]'
__Violet='\[\e[35m\]'
__Magenta='\[\e[01;36m\]'
__Red='\[\e[00;31m\]'
__RedBold='\[\e[31;01m\]'
__RedBoldLight='\[\e[91;01m\]'
__Green='\[\e[00;32m\]'
__GreenBold='\[\e[01;32m\]'
__RedLight='\[\e[22;91m\]'
__GreenLight='\[\e[01;92m\]'
__YellowLight='\[\e[01;93m\]'
__VioletLight='\[\e[95m\]'
__White='\[\e[00;37m\]'
__WhiteBoldLight='\[\e[01;97m\]'
__WhiteBackground='\[\e[01;40m\]'
__Yellow='\[\e[00;33m\]'
__YellowBold='\[\e[01;33m\]'
__Reset='\[\e[00m\]'
# __FancyX='\342\234\227'
# __Checkmark='\342\234\223'
__FancyX='✘'
__Checkmark='✔'

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
        . <(dircolors -b "$HOME/.dircolors")
    else
        . <(dircolors -b "$HOME/.dircolors")
    fi
    _COLOR_ALWAYS_ARG='--color=always' # FIXME: makes no sense for this to be inside this block
fi

## Global colouriser used all around to make everything even gayer
_e "grc" && GRC="grc -es "

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
    local GET_NEARBY=0
    local MAX_RESULTS=1000  # Limit total results to prevent hanging
    local result_count=0
    # Determine the padding length based on the most recent history number
    local max_number_length=$(history | tail -n 1 | awk '{print length($1)}')
    # Check if first argument is a number for nearby context
    if [[ $1 =~ ^[0-9][0-9]*$ ]]; then
        GET_NEARBY=1
        local target_num="$1"
        local context=30  # Number of lines before/after
    fi
    local query="$*"
    # Print header
    printf "\e[01;95m=== Search Results ===\e[00m\n"
    # Process history entries immediately using process substitution
    if [[ $GET_NEARBY == 1 ]]; then
        # For numeric search, collect entries before and after the target number
        mapfile -t matching_entries < <(
            LANG=C history | \
            awk -v target="$target_num" -v ctx="$context" '
                match($0, /^[ ]*[0-9]+/) {
                    num = substr($0, RSTART, RLENGTH)
                    num = num + 0  # Convert to number, trimming spaces
                    entry = substr($0, RSTART + RLENGTH)
                    if (num >= target - ctx && num <= target + ctx) {
                        print num entry
                    }
                }' 2>/dev/null
        )

        for entry in "${matching_entries[@]}"; do
            if [[ -n "$entry" ]]; then
                local number="${entry%% *}"
                local cmd="${entry#* }"
                # Highlight the target line
                if [[ $number == "$target_num" ]]; then
                    printf "\e[01;96m%-*s \e[00m\e[33m%s\e[00m\n" "$max_number_length" "$number" "$cmd"
                else
                    printf "\e[01;96m%-*s \e[00m%s\n" "$max_number_length" "$number" "$cmd"
                fi
            fi
        done
    else
        # For text search, process and print matches immediately
        local seen_commands=()
        while IFS=$'\n' read -r entry; do
            ((result_count++))
            # Break if we've hit the maximum results
            if [[ $result_count -gt $MAX_RESULTS ]]; then
                printf "\e[01;93m=== Results limited to %d matches ===\e[00m\n" "$MAX_RESULTS"
                break
            fi
            local number="${entry%% *}"
            local cmd="${entry#* }"
            seen_commands+=("$cmd")
            # Highlight matching parts
            local highlighted_cmd
            highlighted_cmd="${cmd//$query/$(printf '\e[33m%s\e[00m' "$query")}"
            if [[ "$highlighted_cmd" == "" ]]; then
                highlighted_cmd="$cmd"
            fi
            printf "\e[01;96m%-*s \e[00m%s\n" "$max_number_length" "$number" "$highlighted_cmd"
        done < <(history | grep -i -- "$query")
    fi
    printf "\e[01;95m================\e[00m\n"
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
    "/var/cache/pacman/pkg/"
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


_e "blkid" && alias blkid="${GRC}blkid"
_e "docker" && alias docker="${GRC}docker"
_e "docker-compose" && alias "ocker-compose='${GRC}docker-compose"
_e "docker-machine" && alias "ocker-machine='${GRC}docker-machine"
_e "efibootmgr" && alias efibootmgr="${GRC}efibootmgr"
_e "du" && alias du="${GRC}du -h"
_e "free" && alias free="${GRC}free"
_e "fdisk" && alias fdisk="${GRC}fdisk"
_e "findmnt" && alias findmnt="${GRC}findmnt"
_e "make" && alias make="${GRC}make"
_e "gcc" && alias gcc="${GRC}gcc"
_e "g++" && alias g+"='${GRC}g++"
_e "id" && alias id="${GRC}id"
_e "ip" && alias ip="${GRC}ip"
_e "iptables" && alias iptables="${GRC}iptables"
_e "journalctl" && alias journalctl="${GRC}journalctl"
_e "kubectl" && alias kubectl="${GRC}kubectl"
_e "lsof" && alias lsof="${GRC}lsof"
_e "lsblk" && alias lsblk="${GRC}lsblk"
_e "lspci" && alias lspci="${GRC}lspci"
_e "netstat" && alias netstat="${GRC}netstat"
_e "ping" && alias ping="${GRC}ping"
_e "traceroute" && alias traceroute="${GRC}traceroute"
_e "traceroute6" && alias traceroute6="${GRC}traceroute6"
_e "dig" && alias dig="${GRC}dig"
_e "mount" && alias mount="${GRC}mount"
_e "ps" && alias ps="${GRC}ps"
_e "mtr" && alias mtr="${GRC}mtr"
_e "semanage" && alias semanage="${GRC}semanage"
_e "getsebool" && alias getsebool="${GRC}getsebool"
_e "ifconfig" && alias ifconfig="${GRC}ifconfig"
_e "sockstat" && alias sockstat="${GRC}sockstat"

## Navigation
alias ls="${GRC}ls -ltr --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"
alias g="xdg-open"


### Python
if _e python || _e python3; then
    ##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    ##  |d|i|s|a|b|l|e|_|v|e|n|v|_|p|r|o|m|p|t|
    ##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    ## Disables the native embedded venv prompt so we can make our own
    export VIRTUAL_ENV_DISABLE_PROMPT=0
    function _virtualenv_info() {
        local venv_name=""

        if [[ -n "$VIRTUAL_ENV" || -n "$_PYENV_INITIALIZED" ]]; then
            venv_name=$(python -V)
            venv_name="${venv_name#Python }"
            if [[ -n "$VIRTUAL_ENV" ]]; then
                venv_name="py${venv_name%.*}:${VIRTUAL_ENV##*/}"
            else
                venv_name="py${venv_name%.*}"
            fi

            echo "($venv_name)"
        fi
    }

    if _e pyenv; then
        pyenv() {
            if [[ -z $_PYENV_INITIALIZED ]]; then
                _PYENV_INITIALIZED=1
                eval "$(command pyenv init -)"
            fi
            pyenv "$@"
        }
        if _e virtualenv; then
            alias virtualenv="virtualenv -p \$(pyenv which python)"
        fi
    fi

    # Enhanced pip function with additional checks and features
    function pip() {
        local cmd="$1"

        if [[ "$cmd" == "install" && -n "$VIRTUAL_ENV" ]]; then
            local packages=()
            local flags=()
            local has_flags=0

            # Process arguments to check for flags
            for arg in "$@"; do
                if [[ "$arg" != -* && "$arg" != "install" ]]; then
                    packages+=("$arg")
                fi
            done

            command pip "$@"
            error_code=$?

            # Proceed only if there are packages and no flags
            if [[ ${#packages[@]} -gt 0 && $error_code -eq 0 ]]; then
                # Find requirements.txt file in the current or parent directories
                local cur_dir="$PWD"
                local req_file=""

                while [ "$cur_dir" != "/" ]; do
                    if [ -f "$cur_dir/requirements.txt" ]; then
                        req_file="$cur_dir/requirements.txt"
                        break
                    fi
                    cur_dir=$(dirname "$cur_dir")
                done

                # Read existing packages from requirements.txt
                local req_packages=()
                if [[ -f "$req_file" ]]; then
                    # Read package names from requirements.txt
                    # Remove comments and blank lines
                    while read -r line; do
                        line=$(echo "$line" | sed 's/#.*//g' | xargs)
                        if [[ -n "$line" ]]; then
                            pkg_name=$(echo "$line" | cut -d'=' -f1 | cut -d'<' -f1 | cut -d'>' -f1)
                            req_packages+=("$pkg_name")
                        fi
                    done < "$req_file"
                fi

                # Read packages from temporary list
                local dir_hash=$( echo "$PWD" | md5sum | cut -d' ' -f1)
                mkdir -p "/tmp/pip"
                local tmp_file="/tmp/pip/$dir_hash.txt"
                local tmp_packages=()
                if [[ -f "$tmp_file" ]]; then
                    while read -r line; do
                        tmp_packages+=("$line")
                    done < "$tmp_file"
                fi

                # Combine req_packages and tmp_packages
                local known_packages=("${req_packages[@]}" "${tmp_packages[@]}")

                # Check if any of the installed packages are not in known_packages
                local new_packages=()
                for pkg in "${packages[@]}"; do
                    found=0
                    for known_pkg in "${known_packages[@]}"; do
                        if [[ "$pkg" == "$known_pkg" ]]; then
                            found=1
                            break
                        fi
                    done
                    if [[ $found -eq 0 ]]; then
                        new_packages+=("$pkg")
                    fi
                done

                # Only prompt if at least one new package
                if [[ ${#new_packages[@]} -gt 0 ]]; then
                    echo -e "\e[01;91m\nInstallation successful."
                    echo -e "\e[00;96mDo you want to add installed packages to requirements.txt? [y/N] \e[00m"
                    read -r user_input
                    if [[ "$user_input" =~ ^[Yy]$ ]]; then
                        # Add the new packages to the temporary list
                        for pkg in "${new_packages[@]}"; do
                            # Avoid duplicates in the temporary list
                            if [[ -f "$tmp_file" ]]; then
                                if ! grep -Fxq "$pkg" "$tmp_file"; then
                                    echo "$pkg" >> "$tmp_file"
                                fi
                            else
                                echo "$pkg" >> "$tmp_file"
                            fi
                        done

                        # If requirements.txt not found, create it in the current directory
                        if [[ -z "$req_file" ]]; then
                            req_file="$PWD/requirements.txt"
                            touch "$req_file"
                            echo -e "\e[01;96mCreated new requirements.txt at $req_file.\e[00m"
                        fi
                        # Read the temporary list and add packages to requirements.txt
                        if [[ -f "$tmp_file" ]]; then
                            while read -r pkg; do
                                pkg_name=$(echo "$pkg" | cut -d'=' -f1 | cut -d'<' -f1 | cut -d'>' -f1)
                                # Avoid duplicates in requirements.txt
                                if ! grep -Eq "^$pkg_name(==|>=|<=|~=|!=|>|<|$)" "$req_file"; then
                                    # Retrieve package information
                                    local pkg_info
                                    pkg_info=$(pip show "$pkg")
                                    if [[ -n "$pkg_info" ]]; then
                                        local name version
                                        name=$(echo "$pkg_info" | grep '^Name:' | awk '{print $2}')
                                        version=$(echo "$pkg_info" | grep '^Version:' | awk '{print $2}')
                                        if [[ -n "$name" && -n "$version" ]]; then
                                            echo "${name}==${version}" >> "$req_file"
                                        else
                                            echo "$pkg" >> "$req_file"
                                        fi
                                    else
                                        echo -e "\e[01;93mDidn't find package information for $pkg.\e[00m"
                                    fi
                                fi
                            done < "$tmp_file"
                            echo -e "\n\e[01;92mAdded packages to $req_file:\e[00m"
                            echo -e "\e[97m$(cat "$req_file")\e[00m"
                            # Clear the temporary list
                            rm "$tmp_file"
                        fi
                    else
                        # Add the current packages to the temporary list
                        # if the user doesn't want to add them to requirements.txt
                        for pkg in "${req_packages[@]}"; do
                            if ! grep -qm1 "$pkg" "$tmp_file"; then
                                echo "$pkg" >> "$tmp_file"
                            fi
                        done
                    fi
                fi
            fi
        elif [[ "$cmd" == "uninstall" && -n "$VIRTUAL_ENV" && $error_code -eq 0 ]]; then
            # Remove packages from the temporary list
            local tmp_file="/tmp/pip_installed_packages.txt"
            if [[ -f "$tmp_file" ]]; then
                local tmp_packages=()
                while read -r line; do
                    tmp_packages+=("$line")
                done < "$tmp_file"

                local updated_tmp_packages=()
                for pkg in "${tmp_packages[@]}"; do
                    remove_pkg=0
                    for arg in "$@"; do
                        if [[ "$pkg" == "$arg" ]]; then
                            remove_pkg=1
                            break
                        fi
                    done
                    if [[ $remove_pkg -eq 0 ]]; then
                        updated_tmp_packages+=("$pkg")
                    fi
                done

                # Write updated list back to tmp_file
                printf "%s\n" "${updated_tmp_packages[@]}" > "$tmp_file"
            fi
        else
            # Handle all other pip commands normally
            command pip "$@"
        fi
    }
fi

## Node
if _e node; then
    alias node='node --experimental-modules --experimental-repl-await --experimental-vm-modules --experimental-worker --experimental-import-meta-resolve'
fi

## True screen clearing
function clear() {
    echo -en "\033c"
}

## use bat instead of cat if available
function cat() {
    if [[ -t 0 ]] && [[ $# == 1 ]] && _e bat && bat -L | grep -qm1 "[,:]${1##*.}($|,)"; then
        command bat -P "$@"
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
        if [[ $1 == "devices" && ($# == 1) ]] && _e grcat && [[ -f "$HOME/.grc/conf.efibootmgr" ]]; then
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
    alias je='journalctl -efn 100 -o with-unit --no-hostname'
    alias jb='journalctl -b -o with-unit --no-hostname -e'
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
        function yay() {
            if [[ $# == 0 ]]; then
                # if running simply `yay`, then ask for packages to ignore
                command yay --noanswerupgrade -Syu
            fi
            command yay "$@"
        }
    fi
    alias pacman="pacman "
    alias pacs="sudo pacman -S --needed --asdeps"
    alias pacr="sudo pacman -R --recursive --unneeded --cascade"
    alias pacss="pacman -Ss"
    alias paci="pacman -Qi"
    alias pacl="pacman -Ql"
    alias paccache_safedelete="sudo paccache -r && sudo paccache -ruk1"
    # alias yay="yay -Syu --noanswerupgrade"
    complete -F _complete_alias pacs
    complete -F _complete_alias pacr
    complete -F _complete_alias pacss
    complete -F _complete_alias paci
    complete -F _complete_alias pacl
    complete -F _complete_alias paccache_safedelete

    ## Pacman Awesome Updater
    # function pacsyu() {
    #     echo -e "\e[01;93mUpdating pacman repositories...\e[00m"
    #     sudo pacman -Syu

    #     mkdir -p "$HOME/.pacman-updated"
    #     currentUpdatePkgs=$(\pacman -Qu --color never)
    #     previousUpdatePkgs=$(cat .pacman-updated/$(\ls -L .pacman-updated/ | tail -n1))
    #     if [[ "$currentUpdatePkgs" == "$previousUpdatePkgs" ]]; then
    #         echo -e "\e[00;92\nThis is the same list that was previously saved, not saving again.\e[00m"
    #     else
    #         echo -e "\e[01;93m\nSaving log of packages to upgrade...\e[00m"
    #         echo "$currentUpdatePkgs" >"$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)"
    #     fi

    #     echo -e "\e[01;91m\nUpdating pacman packages...\e[00m"
    #     yay -Syu --noanswerupgrade -Syu
    # }

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
    export GIT_MERGE_AUTOEDIT=no # does not open editor when merging
    export GIT_COMPLETION_SHOW_ALL_COMMANDS=1
    # export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

    # Visualize the entire commit tree history in a compact and informative way, displaying commits, branches, merges, and tags.
    alias gitl="git log --graph --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"

    # Display a concise log, highlighting merges and providing patches for individual commits.
    alias gitd="git diff --color --patch-with-stat --ignore-blank-lines --minimal --abbrev --ignore-all-space --color-moved=dimmed-zebra --color-moved-ws=ignore-all-space"

    # Alias for switching branches.
    alias s="git switch"

    # Display the current status, including stash and omitting renames.
    # alias gits='git status --show-stash --no-renames'

    # Commit all staged changes with a given message.
    function gitcam() {
        git commit -a -m "$*"
    }

    # Amend the most recent commit message.
    function gitm() {
        git commit --amend -m "$*"
    }

    function gitr() {
        # Get the remote URL from the current Git repository
        remote_url="$(git config --get remote.origin.url)"

        if [ -n "$remote_url" ]; then
            # Transform the SSH URL to HTTPS if needed
            if [[ "$remote_url" == git@* ]]; then
                remote_url=${remote_url/git@/}
                remote_url=${remote_url/:/\/}
                remote_url="https:\/\/${remote_url%%.git}"
            fi
            xdg-open "$remote_url"
        else
            echo "No remote URL found in the current Git repository."
        fi
    }

    function gits() {
        # Fetching the git status and color-coding changes.
        readarray -t lines < <(git status --show-stash --long | sed '/.*use "git.*$/d')

        current_block=""
        for line in "${lines[@]}"; do
            if [[ $line =~ 'On branch' ]] || [[ $line =~ 'HEAD detached at' ]]; then
                echo -en "\e[01;94m$line.\e[00m\n"
                continue
            elif [[ $line =~ 'Your branch is ' ]]; then
                echo -en "\e[94m${line}\e[00m\n"
                continue
            elif [[ $line =~ 'Please commit or stash' ]]; then
                echo -en "\e[96m$line\e[00m\n"
                continue
            fi

            if [[ $line =~ 'Changes to be committed:' ]]; then
                current_block="staged"
                echo -en "\e[01;32m$line\e[00m\n"
                continue
            elif [[ $line =~ 'Changes not staged for commit:' ]]; then
                current_block="changes"
                echo -en "\e[01;33m$line\e[00m\n"
                continue
            elif [[ $line =~ 'Untracked files:' ]]; then
                current_block="untracked"
                echo -en "\e[01;96m$line\e[00m\n"
                continue
            elif [[ $line =~ 'Unmerged paths:' ]]; then
                current_block="unmerged"
                echo -en "\e[07m$line\e[00m\n"
                continue
            fi

            if [[ $current_block == "staged" ]]; then
                extra="\e[00m"
            elif [[ $current_block == "changes" ]]; then
                extra="\e[00m"
            elif [[ $current_block == "unmerged" ]]; then
                extra="\e[07;01m"
            elif [[ $current_block == "untracked" ]]; then
                extra="\e[96m"
            else
                extra="\e[00m"
            fi

            if [[ $line =~ ^[[:space:]]+[^:]+:[[:space:]].* ]]; then
                status="${line%%:*}"
                path="${line#*:}"
                # strip all spaces from the beginning of path
                path="${path##*( )}"

                if [[ $current_block == "staged" ]]; then
                    emojies=(   "🟣" )
                    case $status in
                      *"modified"*)
                       emoji="🟠"
                       ;;
                      *"deleted"*)
                       emoji="🔴"
                       ;;
                      *"added"*)
                       emoji="🟢"
                       ;;
                      *"new file"*)
                        emoji="🟢"
                       ;;
                      *"renamed"*)
                        emoji="🔵"
                       ;;
                      *)
                        emoji="⚪️"
                       ;;
                    esac
                    # get right emoji for each status
                    echo -e "$extra\e[01;32m     $emoji$line\e[00m"
                elif [[ $status == *"modified"* ]]; then
                    echo -e "$extra\e[33m\tmodified:\t${path}\e[00m"
                elif [[ $status == *"deleted"* ]]; then
                    echo -e "$extra\e[91m\tdeleted: \t${path}\e[00m"
                elif [[ $status == *"added"* ]]; then
                    echo -e "$extra\e[92m\tadded:   \t${path}\e[00m"
                elif [[ $status == *"new file"* ]]; then
                    echo -e "$extra\e[92m\tnew file:\t${path}\e[00m"
                elif [[ $status == *"renamed"* ]]; then
                    echo -e "$extra\e[95m\trenamed: \t${path}\e[00m"
                elif [[ $status == *"typechange"* ]]; then
                    echo -e "$extra\e[93m\ttypechange:\t\e[00m${path}"
                else
                    echo -e "$extra$line"
                fi
            elif [[ $line =~ ^[[:space:]]+.+ && $current_block == "untracked" ]]; then
                echo -e "$extra\e[96m\tuntracked:  \t${line/[[:space:]]/}\e[00m"
            else
                echo -e "$extra$line"
            fi
        done
    }

    # # Display modified, deleted, and new files in a colorful manner. Shows git status with added emphasis on changes.
    # function gitd() {
    #     local -A files

    #     # Fetching diffs and storing them in an associative array.
    #     readarray diffs < <(git diff --color --stat=80 HEAD | sed '$d; s/^ //')
    #     for line in "${diffs[@]}"; do
    #         key=${line// |*/}
    #         files[${key// /}]=$line
    #     done

    #     # Fetching the git status and color-coding changes.
    #     readarray status < <(git status --show-stash --no-renames | sed '/  (use..*)$/d')
    #     for line in "${status[@]}"; do
    #         key=${line//* /}
    #         if [[ $line =~ modified: ]]; then
    #             echo -en "\e[93m\tmodified: \e[01m${files[${key%?}]}\e[00m"
    #         elif [[ $line =~ deleted: ]]; then
    #             echo -en "\e[91m\tdeleted:  \e[01m${files[${key%?}]}\e[00m"
    #         elif [[ $line =~ new\ file: ]]; then
    #             echo -en "\e[92m\tnew file: \e[01m${files[${key%?}]}\e[00m"
    #         elif [[ $line =~ On\ branch ]]; then
    #             echo -en "${line//On branch/On branch\\e[01;94m}\e[00m"
    #         elif [[ $line =~ 'have diverged' ]]; then
    #             echo -en "\e[91m$line\e[00m"
    #         elif [[ $line =~ 'Your branch is ahead' ]]; then
    #             echo -en "\e[92m$line\e[00m"
    #         elif [[ $line =~ 'Your branch is behind' ]]; then
    #             echo -en "\e[93m$line\e[00m"
    #         elif [[ $line =~ 'Changes not staged for commit' ]]; then
    #             echo -en "\e[95m$line\e[00m"
    #         elif [[ $line =~ 'Changes to be committed' ]]; then
    #             echo -en "\e[96m$line\e[00m"
    #         elif [[ $line =~ 'Untracked files' ]]; then
    #             echo -en "\e[97m$line\e[00m"
    #         elif [[ $line =~ 'Stashed changes' ]]; then
    #             echo -en "\e[90m$line\e[00m"
    #         else
    #             echo -en "$line"
    #         fi
    #     done
    # }

    # Clean up stale local branches that are already merged to the main branch. If the main branch name differs from "master", specify it as an argument.
    function gitcleanbranches() {
        git fetch --prune

        # Determine the master branch name.
        if [[ $# == 1 ]]; then
            master="$1"
        else
            master="master"
        fi

        # Checkout the master branch.
        if ! git checkout $master 2>/dev/null; then
            echo "Pass the master branch name as argv[1]!"
            return
        fi

        # Delete branches already merged to master.
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

    # Autocomplete custom commands
    function _git_local_branches() {
        __gitcomp_direct "$(__git_heads)"
    }

    function _git_conventional_commits_prefixes() {
        __gitcomp "feat: fix: style: refactor: build: perf: ci: docs: test: chore: revert:"
    }
    __git_complete s git_switch
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

    # Load the official git-prompt script if it exists
    if [[ -f "$HOME/.git_prompt.sh" ]]; then
        source "$HOME/.git_prompt.sh"
    elif [[ -f /usr/share/git/git-prompt.sh ]]; then
        source /usr/share/git/git-prompt.sh
    fi

    if [[ -f /usr/share/git/git-prompt.sh || -f "$HOME/.git_prompt.sh" ]]; then
        # export GIT_PS1_SHOWCOLORHINTS=1      # Enable colors (matches `git status --short` colors)
        export GIT_PS1_SHOWDIRTYSTATE=1     # Show unstaged (*) and staged (+) changes
        # export GIT_PS1_SHOWSTASHSTATE=1      # Show if there's a stash ($)
        # export GIT_PS1_SHOWUNTRACKEDFILES=1  # Show if there are untracked files (%)
        export GIT_PS1_SHOWUPSTREAM="auto"   # Show if behind (<), ahead (>), or diverged (<>)
        export GIT_PS1_STATESEPARATOR=" "    # Clean separator

        function _git_prompt() {
            # Fetch Git status using __git_ps1
            local git_info
            if [[ -n "$(command -v __git_ps1)" ]]; then
                git_info=$(__git_ps1 "%s")
            fi

            # Determine the branch color
            local branch_color="$__Bold$__Green"  # Default: Clean branch
            if [[ "$git_info" =~ /([0-9a-f\.]+)/ ]]; then
                branch_color="$__Bold$__Red"      # Detached HEAD
            elif [[ "$git_info" == *"|"* ]]; then
                branch_color="$__Bold$__RedLight" # Conflict (Rebase/Merge in progress)
            elif [[ "$git_info" == *"*"* ]]; then
                branch_color="$__Bold$__Yellow"   # Unstaged changes
            fi

            # Format upstream indicators
            if [[ "$git_info" == *"<>"* ]]; then
                git_info="${git_info//<>/$__Bold$__RedLight<>$__Reset}" # Diverged (light red)
            else
                git_info="${git_info//</$__Bluelly↓$__Reset}"  # Behind upstream (blue)
                git_info="${git_info//>/$__Bluelly↑$__Reset}"  # Ahead upstream (blue)
            fi

            # Remove `*` (unstaged indicator)
            git_info="${git_info//\*/}"
            # Highlight staged changes (`+`) in bold green
            git_info="${git_info//+/$__Bold$__Green+$__Reset}"
            # Remove `=` (no-op, since it won’t be displayed anyway)
            git_info="${git_info//=/}"
            # Remove `%` (untracked files indicator)
            # git_info="${git_info//%/}"
            # Remove ` ` (untracked files indicator)
            git_info="${git_info// /}"

            # Return formatted Git prompt
            [[ -n "$git_info" ]] && echo -ne " ${branch_color}[${git_info}${branch_color}]$__Reset"
        }
    else
        function _git_prompt() {
            true
        }
    fi
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

if [[ ! -s "$HOME/.emishrc_last_check" ]]; then
    [[ "$PS1" ]] && _changelog && date +%s >"$HOME/.emishrc_last_check"
else
    [[ "$PS1" ]] && _e "fortune" "cowthink" "lolcat" && [[ -s "$HOME/.emishrc_last_check" ]] && fortune -s -n 200 | PERL_BADLANG=0 cowthink | lolcat -F 0.1 -p 30 -S 1
fi

function _pre_command() {
    # Capture last entered command, including aliases, without history number
    local history_entry
    history_entry="$(HISTTIMEFORMAT='' history 1 2>/dev/null)"

    # Use built-in Bash expansion to strip history number efficiently
    local current_cmd="${history_entry#*[0-9] }"

    # Fast ignore certain commands
    [[ "$current_cmd" =~ ^(echo|printf|cd|ls|_set_prompt|__vte_prompt_command|\033]0) ]] && return
    [[ "$BASH_COMMAND" =~ ^(echo|printf|cd|ls|_set_prompt|__vte_prompt_command|\033]0) ]] && return

    # Fastest way to set terminal title
    local prefix
    [[ -n "$SSH_CLIENT" ]] && prefix="[SSH] "

    printf "\033]0;%s%s\007" "$prefix" "$current_cmd"

    # Reset colors (fastest)
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

    # Prints  ---\n\n after previous command without spawning
    # a newline after it, so you can actually easily notice
    # if it's output has an EOF linebreak.
    PS1="$__Yellow---$__Reset\\n\\n"

    # Prints the error code
    if [[ $_last_command == 0 ]]; then
        PS1+="$__GreenBold$__Checkmark 000 "
    else
        PS1+="$__RedBold$__FancyX $(printf "%03d" $_last_command) "
    fi

    PS1+="${_ENV_COLOR}${__Bold}\\u${__ResetBold}@${_HOSTNAME}"
    ## Nicely shows you're in a python virtual environment
    [[ -n "$VIRTUAL_ENV" || -n $_PYENV_INITIALIZED ]] && PS1+=" $__Magenta$(_virtualenv_info)"
    PS1+="$(_git_prompt)"
    PS1+="$_ENV_COLOR$__Reset $__Blue\\w"

    # Sets the prompt color according to
    # user (if logged in as root gets red)
    if [[ $(id -u) -eq 0 ]]; then
        PS1+="\\n${__RedBold}\\\$ ${__RedLight}"
    else
        PS1+="\\n${__YellowBold}\\\$ ${__Yellow}"
    fi

    # Aligns stuff when you don't close quotes
    PS2="| "

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
    PS1RHS_stripped=$(echo "$PS1RHS" | sed -e $'s,\x1B\[[0-9;]*[a-zA-Z],,g')

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
