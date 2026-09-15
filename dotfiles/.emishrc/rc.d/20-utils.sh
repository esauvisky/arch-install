#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

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
# --- Standard ANSI Colors ---
__Bold='\[\e[01m\]'
__ResetBold='\[\e[22m\]'
__Reset='\[\e[00m\]'

__Blue='\[\e[00;34m\]'
__BlueLight='\[\e[22;94m\]'
__BlueBold='\[\e[01;34m\]'
__BlueLightBold='\[\e[01;94m\]'

__White='\[\e[00;37m\]'
__WhiteBold='\[\e[01;37m\]'
__WhiteLight='\[\e[22;97m\]'
__WhiteLightBold='\[\e[01;97m\]'
__WhiteBackground='\[\e[01;40m\]'

__Violet='\[\e[00;35m\]'
__VioletBold='\[\e[01;35m\]'
__VioletLight='\[\e[22;95m\]'
__VioletLightBold='\[\e[01;95m\]'

__Cyan='\[\e[00;36m\]'
__CyanBold='\[\e[01;36m\]'
__CyanLight='\[\e[22;96m\]'
__CyanLightBold='\[\e[01;96m\]'

__Red='\[\e[00;31m\]'
__RedBold='\[\e[01;31m\]'
__RedLight='\[\e[22;91m\]'
__RedLightBold='\[\e[01;91m\]'

__Green='\[\e[00;32m\]'
__GreenBold='\[\e[01;32m\]'
__GreenLight='\[\e[22;92m\]'
__GreenLightBold='\[\e[01;92m\]'

__Yellow='\[\e[00;33m\]'
__YellowBold='\[\e[01;33m\]'
__YellowLight='\[\e[22;93m\]'
__YellowLightBold='\[\e[01;93m\]'

# --- Extended 256-Colors ---

# Orange (Good for warnings/dirty state)
__Orange='\[\e[38;5;208m\]'
__OrangeBold='\[\e[1;38;5;208m\]'
__OrangeLight='\[\e[38;5;214m\]'

# Gray (Good for timestamps/brackets)
__GrayDark='\[\e[38;5;240m\]'
__Gray='\[\e[38;5;246m\]'
__GrayLight='\[\e[38;5;252m\]'

# Pink (Distinct from Violet/Magenta)
__Pink='\[\e[38;5;198m\]'
__PinkBold='\[\e[1;38;5;198m\]'

# Lime (Brighter than Green)
__Lime='\[\e[38;5;118m\]'
__LimeBold='\[\e[1;38;5;118m\]'

# Teal (Distinct from Cyan)
__Teal='\[\e[38;5;37m\]'
__TealBold='\[\e[1;38;5;37m\]'

# Purple (Darker/Richer than Violet)
__Purple='\[\e[38;5;141m\]'
__PurpleBold='\[\e[1;38;5;141m\]'

# Brown
__Brown='\[\e[38;5;94m\]'

# Symbols
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
if _e dircolors && [[ -f $HOME/.dircolors ]]; then
    . <(dircolors -b "$HOME/.dircolors")
    _COLOR_ALWAYS_ARG='--color=always' # FIXME: makes no sense for this to be inside this block
fi

## Global colouriser used all around to make everything even gayer
_e "grc" && GRC="grc -es --colour=on "
