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
## Used for version checking
export _RCVERSION=39
export _DATE="Feb 18th, 2026"
function _changelog() {
    local a=$'\e[36;03m'       # cyan
    local r=$'\e[00m'          # reset
    local n=$'\e[07m'          # inverted bg
    local b=$'\e[1m'           # bold
    local y=$'\e[33;01m'       # yellow
    local i=$'\e[00m\e[96;03m' # emphasis
    local g=$'\e[32;01m'       # green
    local w=$'\e[97;01m'       # white bold
    local c=$'\e[97m'          # code
    local f=$'\e[5;91;01m'     # flashing red bold

    echo "${g}emi's .bashrc${r}
${y}Changelog 39 ($_DATE)${r}" | sed -e :a -e "s/^.\{1,$(($(tput cols) + 10))\}$/ & /;ta"
    echo -e "
    ${a}Code quality improvements, environment stability, and git infrastructure hardening.${r}

  ${r}- ${b}Removed Broken Docker Aliases.${r}
    ${a}Cleaned up ${c}docker-compose${r}${a} and ${c}docker-machine${r}${a} aliases that were no longer functional.${r}

  ${r}- ${b}Refactored Git Helpers.${r}
    ${a}Consolidated and improved ${c}ai stash${r}${a}, ${c}ai status${r}${a}, ${c}ai sync${r}${a}, and prompt logic for better maintainability.${r}

  ${r}- ${b}Enhanced Prompt Stability.${r}
    ${a}Extended and standardized prompt color palette with better condition checks for startup messages.${r}

  ${r}- ${b}Hardened Environment Management.${r}
    ${a}Improved command existence checks, prevented duplicate PATH entries, and removed unused fzf helper.${r}

  ${r}- ${b}Node/Git-Bash Compatibility.${r}
    ${a}Fixed node alias conflicts on Git Bash environments to prevent shell startup issues.${r}

  ${r}- ${b}Updated API Key Documentation.${r}
    ${a}Clarified that GEMINI_API_KEY should be stored in ${c}$HOME/.bash_custom${r}${a} for uncommitted settings.${r}

   ${y}Tip: Store local configuration and API keys in ${c}$HOME/.bash_custom${r}${y} (git-ignored).${r}
   ${y}     For troubleshooting, use ${c}BASHRC_DISABLE_AI=1${r}${y} to disable all AI features.${r}
  "
}

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

(check_updates 2>/dev/null & disown)

## Returns if the current shell is a SSH shell.
# @see https://unix.stackexchange.com/a/12761
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
    # type -P "$1" >/dev/null 2>&1 && return 0
    hash "$@" >/dev/null 2>&1 && return 0
    return 1
}

export BASHRC_DISABLE_AI=0
export BASHRC_GEMINI_MODEL="gemini-flash-lite-latest"
function _gemini_query() {
    # 1. Kill Switch & Config Checks
    if [[ "$BASHRC_DISABLE_AI" -eq 1 ]]; then
        echo "AI features are disabled (BASHRC_DISABLE_AI=1)." >&2
        return 1
    fi

    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: GEMINI_API_KEY not set." >&2
        return 1
    fi

    if ! _e "jq" || ! _e "curl"; then
        echo "Error: 'jq' and 'curl' are required." >&2
        return 1
    fi

    local system_instruction="$1"
    local user_input="$2"

    # 2. Construct JSON Payload securely with jq
    # We combine system and user prompt for simplicity with the v1beta API
    local payload
    payload=$(jq -n \
              --arg sys "$system_instruction" \
              --arg usr "$user_input" \
              '{
                contents: [{
                  parts: [{text: ($sys + "\n\n" + $usr)}]
                }],
                generationConfig: {
                    temperature: 0.2
                }
              }')

    # 3. Call Gemini API
    local response
    response=$(curl -s -X POST \
         -H "Content-Type: application/json" \
         "https://generativelanguage.googleapis.com/v1beta/models/${BASHRC_GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}" \
         -d "$payload")

    # 4. Extract and Clean Output
    local content
    content=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty')

    if [[ -n "$content" && "$content" != "null" ]]; then
        # Strip Markdown code blocks (```bash ... ```) and whitespace
        echo "$content" | sed 's/^```[a-z]*//; s/```$//; s/^`//; s/`$//' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
        return 0
    else
        # verbose error for debugging only if needed
        # echo "Debug API Response: $response" >&2
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
    if [[ -d $dir && ! "$PATH" =~ (^|:)"$dir"(:|$) ]]; then
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

    unalias myalias 2>/dev/null || true # for windows users because git bash already aliases node to something else
    # alias node='node --experimental-modules --experimental-repl-await --experimental-vm-modules --experimental-worker --experimental-import-meta-resolve'
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

##  +-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
##  |B|a|s|h| |H|i|s|t|o|r|y| |C|l|e|a|n|u|p|
##  +-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
## Cleans up your bash history file by removing duplicates and the top 5% long entries.
cleanup_bash_history() {
    local file="$HOME/.bash_eternal_history"
    if [[ ! -f "$file" ]]; then
        echo "No history file found at $file. Nothing to do."
        return
    elif ! _e "awk" || ! _e "sort" || ! _e "head" || ! _e "cut" || ! _e "wc"; then
        echo "awk, sort, head, cut, and wc are required for this function."
        return
    fi

    # Temporary files for our intermediate data.
    local tmp_blocks tmp_info tmp_new tmp_remove_ids tmp_final
    tmp_blocks=$(mktemp) || return 1
    tmp_info=$(mktemp) || return 1
    tmp_new=$(mktemp) || return 1
    tmp_remove_ids=$(mktemp) || return 1
    tmp_final=$(mktemp) || return 1

    total_commands=$(grep -c '^#[0-9][0-9]*$' "$file")
    five_percent=$((total_commands/20))

    echo "Before cleanup, history file size: $(wc -c < "$file") bytes."
    echo "Total commands: $total_commands. Will remove the longest $five_percent."

    # Step 1. Split the file into command blocks.
    # Each block starts with a timestamp line (a line that starts with '#' and digits)
    # and includes all following lines until the next timestamp line.
    # We write each block to tmp_blocks with markers and also output block id and its length.
    awk -v out_blocks="$tmp_blocks" -v out_info="$tmp_info" '
        BEGIN { block_id = 0; block = "" }
        # When a line looks like a timestamp line…
        /^#[0-9]+$/ {
        # If we already have a block, output it first.
        if (block != "") {
            print "BLOCKSTART " block_id >> out_blocks
            printf "%s", block >> out_blocks
            print "BLOCKEND" >> out_blocks
            # Record block id and its length (number of characters).
            print block_id "\t" length(block) >> out_info
        }
        block_id++
        block = $0 "\n"
        next
        }
        # Otherwise, continue appending to the current block.
        { block = block $0 "\n" }
        END {
        if (block != "") {
            print "BLOCKSTART " block_id >> out_blocks
            printf "%s", block >> out_blocks
            print "BLOCKEND" >> out_blocks
            print block_id "\t" length(block) >> out_info
        }
        }
    ' "$file"

    # Step 2. Find the blocks with the greatest character count.
    # Sort descending by length (field 2), pick top $five_percent, and extract the block ids.
    sort -k2,2nr "$tmp_info" | head -n "$five_percent" | cut -f1 > "$tmp_remove_ids"

    # Step 3. Reassemble the history file, skipping blocks whose id is in the removal list.
    # We read the file we generated with block markers.
    awk -v remove_ids_file="$tmp_remove_ids" '
        BEGIN {
        # Read the list of block ids to remove into an array.
        while (getline id < remove_ids_file) {
            remove[id] = 1
        }
        in_block = 0
        skip = 0
        }
        # Identify the start of a block.
        /^BLOCKSTART/ {
        in_block = 1
        split($0, a, " ")
        current_id = a[2]
        skip = (current_id in remove)
        # Print the block content (including the timestamp) only if not skipping.
        next
        }
        # Identify the end of a block.
        /^BLOCKEND/ {
        in_block = 0
        skip = 0
        next
        }
        # For lines inside a block, print them only if we are not skipping.
        {
        if (in_block && !skip) print
        }
    ' "$tmp_blocks" > "$tmp_new"

    echo "After long-entry removal, history file size: $(wc -c < "$tmp_new") bytes."

    # Step 4. Remove duplicate commands, keeping only the latest usage.
    # Here, we treat a "block" as starting with a timestamp line (matching ^#[0-9]+$)
    # followed by one or more lines (the command itself). We compare the command portion (i.e. all lines except the first)
    # and if duplicates are found, only the last occurrence is kept.
    awk '
        # Helper function to trim whitespace.
        function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }

        # When a line is a timestamp line, it signals the start of a new block.
        /^#[0-9]+$/ {
        if (block != "") {
            blocks[++n] = block
            # Split block into lines; assume first line is timestamp.
            num = split(block, arr, "\n")
            cmd = ""
            for(i = 2; i <= num; i++) {
            cmd = cmd arr[i] "\n"
            }
            commands[n] = trim(cmd)
        }
        block = $0 "\n"
        next
        }
        { block = block $0 "\n" }
        END {
        if (block != "") {
            blocks[++n] = block
            num = split(block, arr, "\n")
            cmd = ""
            for(i = 2; i <= num; i++) {
            cmd = cmd arr[i] "\n"
            }
            commands[n] = trim(cmd)
        }
        # Process blocks in reverse order so that the first time we encounter a command (from the bottom)
        # is its latest occurrence.
        for(i = n; i >= 1; i--) {
            if (!(commands[i] in seen)) {
            keep[i] = 1
            seen[commands[i]] = 1
            } else {
            keep[i] = 0
            }
        }
        # Output blocks in the original order (chronologically) if marked to keep.
        for(i = 1; i <= n; i++) {
            if (keep[i])
            printf "%s", blocks[i]
        }
        }
    ' "$tmp_new" > "$tmp_final"

    echo "After duplicate removal, history file size: $(wc -c < "$tmp_final") bytes."

    echo "Backing up $file to $file.bak"
    cp "$file" "$file.bak"
    echo "Moving cleaned file to $file"
    cp "$tmp_final" "$file"

    command rm -f "$tmp_blocks" "$tmp_info" "$tmp_new" "$tmp_remove_ids" "$tmp_final"

    echo "Done. Restart your shells or they will overwrite the new history file with the old one."
}

## Quick LLM assistant for shell commands
# - Use: ask <question>          (prints command; then press ↑ to bring it back, or use Ctrl+O workflow below)
# - Or:  type your question at the prompt, then press Ctrl+O (replaces the line with the command)
# - If you type: ask <question> at the prompt, Ctrl+O will strip the leading "ask " automatically.

ask() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ask <question>"
        echo "Example: ask make git ignore changes in filemodes for this repo"
        return 1
    fi

    local question="$*"
    local sys_prompt="You are a helpful shell command assistant. Respond ONLY with the exact one-liner command to run. No explanations, no markdown, no backticks."

    local content
    if content=$(_gemini_query "$sys_prompt" "Task: $question"); then
        # Print the command in Cyan
        echo -e "\e[36m$content\e[0m"

        # Add both prompt and command to history
        history -s "ask $question"
        history -s "$content"

        # Tell user how to use it safely without xdotool
        echo "Press ↑ to bring the command back. You can also just type the prompt and press Ctrl+O to auto-fill the command line."
    else
        echo "Failed to get response from Gemini." >&2
        return 1
    fi
}

__ask_ctrl_o() {
    # Take whatever is currently on the readline buffer as the "question"
    local q="$READLINE_LINE"

    # If the user typed "ask ..." and hit Ctrl+O, strip the prefix.
    if [[ "$q" == ask\ * ]]; then
        q="${q#ask }"
    fi

    # Trim leading/trailing whitespace
    q="${q#"${q%%[![:space:]]*}"}"
    q="${q%"${q##*[![:space:]]}"}"

    # If empty, do nothing
    [[ -n "$q" ]] || return 0

    local sys_prompt="You are a helpful shell command assistant. Respond ONLY with the exact one-liner command to run. No explanations, no markdown, no backticks."

    local cmd
    cmd="$(_gemini_query "$sys_prompt" "Task: $q")" || {
        # Keep the original line if the LLM call fails
        return 0
    }

    # Replace the current command line with the suggested command and move cursor to end
    READLINE_LINE="$cmd"
    READLINE_POINT=${#READLINE_LINE}

    # Append both prompt and command to history (same behavior as 'ask')
    history -s "ask $q"
    history -s "$cmd"
}

# Bind Ctrl+O to generate + insert command (bash/readline)
bind -x '"\C-o":__ask_ctrl_o'


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
    alias je='journalctl -efn 100 --no-hostname'
    alias jb='journalctl -eb --no-hostname'
    function st() {
        if _systemctl_exists_user "${1}"; then
            journalctl --output cat -lxe _SYSTEMD_USER_UNIT="${1}"
        else
            journalctl --output cat -lxe _SYSTEMD_UNIT="${1}"
        fi
    }
    function _complete_journalctl() {
        local cur
        local units
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}

        # Get loaded system and user units of specific types using systemctl
        # --all includes inactive units which might still have logs
        # --no-legend removes the header line
        # --no-pager prevents output from being piped to less
        units=$( ( \
                    systemctl list-units --all --no-legend --no-pager --type=service,target,socket ; \
                    systemctl --user list-units --all --no-legend --no-pager --type=service,target,socket 2>/dev/null \
                 ) | awk '{print $1}' | sort -u )
                 # Added 2>/dev/null for the user command to suppress errors if the user manager isn't running

        # Generate completions based on the list of known units
        COMPREPLY=( $(compgen -W "${units}" -- "$cur") )
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
if _e git; then
    export GIT_MERGE_AUTOEDIT=no
    export GIT_COMPLETION_SHOW_ALL_COMMANDS=1

    # gitl remains an alias as it's a specific log view
    alias gitl="git log --graph --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"

    # Removed gitd alias (logic moved to git function)

    function gitm() {
        git commit --amend -m "$*"
    }

    function gits() {
        local current_block="" line status path emoji
        # Define specific colors for echo output
        local c_orange_light='\033[38;5;214m'
        local c_orange_bold='\033[1;38;5;208m'
        local c_reset='\033[0m'

        local -A emoji_map=(
            [modified]="🟠"
            [deleted]="🔴"
            [added]="🟢"
            ["new file"]="🟢"
            [renamed]="🔵"
        )

        while IFS= read -r line; do
            # --- 1. Filter Noise ---

            # A. Rebase/Merge History & Hints
            [[ $line =~ ^[[:space:]]*(pick|drop|edit|squash|fixup|exec|label|reset|merge)[[:space:]] ]] && continue
            [[ $line =~ ^(Last|Next)[[:space:]]commands ]] && continue
            [[ $line =~ ^interactive[[:space:]]rebase[[:space:]]in[[:space:]]progress ]] && continue

            # B. Parenthetical Hints (The heavy lifter)
            # Removes (use "git add"...) (fix conflicts...) (use "git push"...)
            [[ $line =~ ^[[:space:]]*\(.*\)$ ]] && continue

            # C. Specific Messages to Hide
            [[ $line =~ ^nothing\ to\ commit,\ working\ tree\ clean ]] && continue
            [[ $line =~ ^no\ changes\ added\ to\ commit ]] && continue
            [[ $line =~ ^You\ have\ unmerged\ paths\. ]] && continue

            # [NEW] Hide "Up to date" (Prompt already shows this via lack of arrows)
            [[ $line =~ ^Your\ branch\ is\ up\ to\ date\ with ]] && continue

            # [NEW] Hide Ignored files header
            [[ $line =~ ^Ignored\ files: ]] && continue

            # [NEW] Hide simple "On branch" if strictly boring (Prompt shows branch)
            # We keep it if it's "HEAD detached" or complex states, but "On branch main" is noise
            # unless we want to confirm the name explicitly.
            # Commented out by default, uncomment if you trust your prompt 100%
            # [[ $line =~ ^On\ branch\  ]] && continue


            # --- 2. Headers & Coloring ---

            if [[ $line =~ ^(On branch|HEAD detached at) ]]; then
                echo -e "\e[01;94m$line.\e[00m"
                continue
            elif [[ $line =~ ^Your\ branch\ is ]]; then
                echo -e "\e[94m$line\e[00m"
                continue
            elif [[ $line =~ ^You\ are\ currently\ rebasing ]]; then
                echo -e "\e[01;96m$line\e[00m"
                continue
            fi

            # --- DIVERGENCE MESSAGE REPLACEMENT ---
            if [[ $line =~ ^Your\ branch\ and\ .*have\ diverged ]]; then
                echo -e "${c_orange_light}${line}${c_reset}"
                continue
            elif [[ $line =~ ^and\ have\ .*different\ commits ]]; then
                echo -e "${c_orange_light}${line}${c_reset}"
                echo ""
                echo -e "${c_orange_bold}You will need rewrite the history if you want to push to"
                echo -e "the remote repository using \"git push --force\".${c_reset}"
                continue
            fi

            # Add spacing before sections
            if [[ $line =~ ^(Changes|Untracked|Unmerged) ]]; then
                echo ""
            fi

            case "$line" in
                *"Changes to be committed:"*)
                    current_block="staged"
                    echo -e "\e[01;32m$line\e[00m"
                    continue
                    ;;
                *"Changes not staged for commit:"*)
                    current_block="changes"
                    echo -e "\e[01;33m$line\e[00m"
                    continue
                    ;;
                *"Untracked files:"*)
                    current_block="untracked"
                    echo -e "\e[01;96m$line\e[00m"
                    continue
                    ;;
                *"Unmerged paths:"*)
                    current_block="unmerged"
                    echo -e "\e[01;31m$line\e[00m"
                    continue
                    ;;
            esac

            # --- 3. File List Processing ---
            if [[ $line =~ ^[[:space:]]+([^:]+):[[:space:]]+(.+)$ ]]; then
                status="${BASH_REMATCH[1]}"
                path="${BASH_REMATCH[2]}"

                case "$current_block" in
                    staged)
                        for key in "${!emoji_map[@]}"; do
                            if [[ $status == *"$key"* ]]; then
                                emoji="${emoji_map[$key]}"
                                break
                            fi
                        done
                        echo -e "\e[01;32m     ${emoji:-⚪️}$line\e[00m"
                        ;;
                    changes)
                        if [[ $status == *modified* ]]; then
                            echo -e "\e[33m\tmodified:\t$path\e[00m"
                        elif [[ $status == *deleted* ]]; then
                            echo -e "\e[91m\tdeleted: \t$path\e[00m"
                        elif [[ $status == *added* || $status == *"new file"* ]]; then
                            echo -e "\e[92m\tnew file:\t$path\e[00m"
                        elif [[ $status == *renamed* ]]; then
                            echo -e "\e[95m\trenamed: \t$path\e[00m"
                        elif [[ $status == *typechange* ]]; then
                            echo -e "\e[93m\ttypechange:\t$path\e[00m"
                        else
                            echo -e "$line"
                        fi
                        ;;
                    unmerged)
                        echo -e "\e[31m\t$status:\t$path\e[00m"
                        ;;
                esac
            elif [[ $line =~ ^[[:space:]]+(.+)$ && $current_block == "untracked" ]]; then
                echo -e "\e[96m\tuntracked:  \t${BASH_REMATCH[1]}\e[00m"
            elif [[ -n $line ]]; then
                 if [[ $line =~ ^Your\ stash\ currently ]]; then
                    echo ""
                    echo -e "\e[37m$line\e[00m"
                 else
                    echo -e "$line"
                 fi
            fi
        done < <(git status --show-stash --long 2>/dev/null)
    }

    function gitcleanbranches() {
        local master="${1:-master}"
        local merge_base commit_hash
        git fetch --prune || return 1
        git checkout "$master" 2>/dev/null || { echo "Pass the master branch name as argv[1]!"; return 1; }
        while IFS= read -r branch; do
            [[ "$branch" == "$master" ]] && continue
            merge_base=$(git merge-base "$master" "$branch" 2>/dev/null) || continue
            commit_hash=$(git rev-parse --verify "$branch" 2>/dev/null) || continue
            [[ "$merge_base" == "$commit_hash" ]] && git branch --delete "$branch"
        done < <(git for-each-ref refs/heads --format='%(refname:short)')
    }

    function _git_sync() {
        local -r bold=$'\033[1m' fgre=$'\033[32m' fblu=$'\033[34m'
        local -r fred=$'\033[31m' fyel=$'\033[33m' fvio=$'\033[35m' end=$'\033[0m'
        local current_branch remote branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        while IFS= read -r remote; do
            [[ -z "$remote" ]] && continue
            git remote update "$remote" --prune 2>&1 | \
                sed "s/ - \[deleted\]..*-> *$remote\/\(.*\)/   ${fyel}Branch ${bold}\1${end}${fyel} was deleted from $remote and will be pruned locally.${end}/"

            while IFS= read -r branch; do
                if ! git rev-parse --abbrev-ref "$branch@{upstream}" &>/dev/null; then
                    if git branch --set-upstream-to="$remote/$branch" "$branch" &>/dev/null; then
                        echo -e "   ${fvio}Branch ${bold}$branch${end}${fvio} was not tracking any remote branch! It was set to track ${bold}$remote/$branch.${end}"
                    fi
                fi
            done < <(git for-each-ref --format='%(refname:short)' refs/heads/*)

            while IFS=' ' read -r rb lb; do
                [[ -z "$rb" || -z "$lb" ]] && continue
                local arb="refs/remotes/$remote/$rb"
                local alb="refs/heads/$lb"
                local nbehind nahead
                nbehind=$(git rev-list --count "$alb..$arb" 2>/dev/null || echo 0)
                [[ $nbehind -eq 0 ]] && continue
                nahead=$(git rev-list --count "$arb..$alb" 2>/dev/null || echo 0)

                if [[ $nahead -gt 0 ]]; then
                    echo -e "   ${fred}Branch ${bold}$lb${end}${fred} is ${bold}$nbehind${end}${fred} commit(s) behind and ${bold}$nahead${end}${fred} commit(s) ahead of ${bold}$remote/$rb${end}${fred}. Could not be fast-forwarded.${end}"
                elif [[ "$lb" == "$current_branch" ]]; then
                    if git merge -q "$arb" 2>/dev/null; then
                        echo -e "   ${fblu}Branch ${bold}$lb${end}${fblu} was ${bold}$nbehind${end}${fblu} commit(s) behind of ${bold}$remote/$rb${end}${fblu}. Fast-forward merge.${end}"
                    else
                        echo -e "   ${fred}${bold}Warning! Branch $lb${end}${fred} (currently checked out) will conflict with new commits incoming from ${bold}$remote/$rb${end}${fred}!${end}"
                        echo -e "   ${fred}You'll need to stash your changes before. Try \`${bold}git stash${end}${fred}\`, \`${bold}git merge${end}${fred}\`, then \`${bold}git stash pop${end}${fred}\`, and good luck!${end}"
                    fi
                else
                    echo -e "   ${fgre}Branch ${bold}$lb${end}${fgre} was ${bold}$nbehind${end}${fgre} commit(s) behind of ${bold}$remote/$rb${end}${fgre}. Resetting local branch to remote.${end}"
                    git branch -f "$lb" -t "$arb" &>/dev/null
                fi
            done < <(git remote show "$remote" -n | awk '/merges with remote/{print $5" "$1}')
        done < <(git remote)
    }

    function _git_ai_stash_message() {
        local diff_content
        diff_content=$(git diff HEAD --no-color 2>/dev/null | head -c 12000)
        [[ -z "$diff_content" ]] && return 1
        echo -ne "\e[35m🤖 Analyzing changes with Gemini...\e[0m\n" >&2
        local sys_prompt="You are a git assistant. Write a git stash message (max 10 words, imperative mood) based on the diff provided. Output ONLY the message text. No quotes, no markdown."
        _gemini_query "$sys_prompt" "$diff_content"
    }

    function git() {
        case "$1" in
            stash)
                if [[ $# -eq 1 || ($# -eq 2 && "$2" == "push") ]]; then
                    local ai_message
                    if ai_message=$(_git_ai_stash_message); then
                        command git stash push -m "🤖 $ai_message"
                    else
                        command git "$@"
                    fi
                    return
                fi
                ;;
            pull)
                [[ $# -eq 1 ]] && { _git_sync; return; }
                ;;
            commit)
                [[ $# -eq 2 && "$2" == "--amend" ]] && { command git commit --amend --no-edit; return; }
                ;;
            # [NEW] Intercept 'status' to use custom gits function
            status)
                if [[ $# -eq 1 ]]; then
                    gits
                    return
                fi
                ;;
            # [NEW] Intercept 'diff' to use custom flags (replacing gitd alias)
            diff)
                shift
                command git diff --color --patch-with-stat --ignore-blank-lines \
                    --minimal --abbrev --ignore-all-space \
                    --color-moved=dimmed-zebra --color-moved-ws=ignore-all-space "$@"
                return
                ;;
        esac
        command git "$@"
    }

    _git_commit() {
        case "$prev" in
            -c|-C) __git_complete_refs; return ;;
            -m) __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert: "; return ;;
        esac
        case "$cur" in
            --cleanup=*) __gitcomp "default scissors strip verbatim whitespace" "" "${cur##--cleanup=}"; return ;;
            --message=*) __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert:" "" "${cur##--message=}"; return ;;
            --reuse-message=*|--reedit-message=*|--fixup=*|--squash=*) __git_complete_refs --cur="${cur#*=}"; return ;;
            --untracked-files=*) __gitcomp "$__git_untracked_file_modes" "" "${cur##--untracked-files=}"; return ;;
            --*) __gitcomp_builtin commit; return ;;
        esac
        if __git rev-parse --verify --quiet HEAD >/dev/null; then
            __git_complete_index_file "--committable"
        else
            __git_complete_index_file "--cached"
        fi
    }

    # =========================================================================
    #  CUSTOM GIT PROMPT
    # =========================================================================
    function _git_prompt() {
        local git_dir
        git_dir=$(git rev-parse --git-dir 2>/dev/null) || return

        local bname=""
        local detached="no"
        local op_text=""     # The text (REBASE, MERGING)
        local op_state="normal"
        local dirty=""
        local staged=""
        local conflict=""
        local upstream_status=""

        # 1. Detect Operation State
        if [ -d "$git_dir/rebase-merge" ]; then
            bname=$(cat "$git_dir/rebase-merge/head-name" 2>/dev/null)
            bname=${bname##refs/heads/}
            op_text="REBASE"
            op_state="rebase"
        elif [ -d "$git_dir/rebase-apply" ]; then
             if [ -f "$git_dir/rebase-apply/rebasing" ]; then
                bname=$(cat "$git_dir/rebase-apply/head-name" 2>/dev/null)
                bname=${bname##refs/heads/}
                op_text="REBASE"
                op_state="rebase"
             elif [ -f "$git_dir/rebase-apply/applying" ]; then
                op_text="AM"
                op_state="rebase"
             else
                op_text="AM/REBASE"
                op_state="rebase"
             fi
        elif [ -f "$git_dir/MERGE_HEAD" ]; then
            op_text="MERGING"
            op_state="merge"
        elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
            op_text="CHERRY-PICKING"
            op_state="merge"
        elif [ -f "$git_dir/REVERT_HEAD" ]; then
            op_text="REVERTING"
            op_state="merge"
        elif [ -f "$git_dir/BISECT_LOG" ]; then
            op_text="BISECTING"
            op_state="bisect"
        fi

        # 2. Get Branch Name
        if [ -z "$bname" ]; then
            if bname=$(git symbolic-ref HEAD 2>/dev/null); then
                bname=${bname##refs/heads/}
            else
                detached="yes"
                bname=$(git describe --tags --exact-match HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
                bname="($bname)"
            fi
        fi

        # 3. Status Flags
        if ! git diff --no-ext-diff --quiet 2>/dev/null; then dirty="*"; fi
        if ! git diff --no-ext-diff --cached --quiet 2>/dev/null; then staged="+"; fi
        if [ "$(git ls-files --unmerged 2>/dev/null)" ]; then conflict="|CONFLICT"; fi

        # 4. Determine Colors
        local frame_color=""
        local branch_color_str=""
        local conflict_color="$__RedBold"
        local op_color="$__RedBold"

        # Set Frame Color based on context
        case "$op_state" in
            rebase) frame_color="$__VioletBold" ;;
            merge)  frame_color="$__VioletBold" ;;
            bisect) frame_color="$__CyanLightBold" ;;
            *)      frame_color="$__Bold$__Gray" ;;
        esac

        # Set Branch Name Color (File State)
        if [[ -n "$dirty" && -n "$staged" ]]; then
            local len=${#bname}
            local half=$((len / 2))
            branch_color_str="$__GreenBold${bname:0:half}$__YellowBold${bname:half}"
        elif [[ -n "$staged" ]]; then
            branch_color_str="$__GreenBold$bname"
        elif [[ -n "$dirty" ]]; then
            branch_color_str="$__YellowLightBold$bname"
        elif [[ "$detached" == "yes" ]]; then
            branch_color_str="$__VioletLightBold$bname"
        else
            branch_color_str="$__Bold$__Gray$bname"
        fi

        # 5. Upstream Arrows & Divergence Override
        local count
        if count=$(git rev-list --count --left-right "@{upstream}"...HEAD 2>/dev/null); then
            local behind=${count%	*}
            local ahead=${count#*	}
            if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
                upstream_status="$__Bold$__OrangeLight<>$__Reset"
                branch_color_str="$__OrangeBold$bname"
            elif [[ "$ahead" -gt 0 ]]; then
                upstream_status="$__BlueLightBold↑$__Reset"
            elif [[ "$behind" -gt 0 ]]; then
                upstream_status="$__YellowLightBold↓$__Reset"
            fi
        fi

        # 6. Build the String
        local pipe_str=""
        if [[ -n "$op_text" ]]; then
            pipe_str="${frame_color}|"
            op_text="${op_color}${op_text}"
        fi

        echo -ne " ${frame_color}[${branch_color_str}${pipe_str}${op_text}${conflict_color}${conflict}${upstream_status}${frame_color}]$__Reset"
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

if [[ ! -s "$HOME/.emishrc_last_check" ]]; then
    [[ "$PS1" ]] && _changelog && date +%s >"$HOME/.emishrc_last_check"
elif [[ $RANDOM -lt 10000 ]]; then
    [[ "$PS1" ]] && _e "fortune" "cowthink" "lolcat" && fortune -s -n 200 | PERL_BADLANG=0 cowthink | lolcat -F 0.1 -p 30 -S 1
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
    [[ -n "$VIRTUAL_ENV" || -n $PYENV_SHELL ]] && PS1+=" $(_python_info)"
    PS1+="$(_git_prompt)"
    PS1+="$_ENV_COLOR$__Reset $__Blue\\w"

    # Sets the prompt color according to
    # user (if logged in as root gets red)
    if [[ $(command id -u) -eq 0 ]]; then
        PS1+="\\n${__RedBold}\\\$ ${__RedLight}"
    else
        PS1+="\\n${__YellowBold}\\\$ ${__Yellow}"
    fi

    # Aligns stuff when you don't close quotes
    PS2="| "

    # Debug (PS4)
    # ** Does not work if set -x is used outside an script :( **
    # It works wonderfully if you copy this to the script and apply set -x there though.
    # PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'

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
    _python_info() {
        local pyenv_version pyenv_origin venv_origin
        local git_root_dir pyenv_info venv_info
        local py_version venv_version
        local py_major py_minor py_patch
        local venv_major venv_minor venv_patch
        local pyenv_major pyenv_minor pyenv_patch

        # Build output
        local out_info="$__BlueLight($__Reset"

        # Cache git root lookup (expensive operation)
        if _e git && [[ -z "$_CACHED_GIT_ROOT" || "$PWD" != "$_CACHED_PWD" ]]; then
            _CACHED_GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
            _CACHED_PWD="$PWD"
        fi
        git_root_dir="$_CACHED_GIT_ROOT"

        # Get current python version (cache this if python doesn't change often)
        # Use a faster approach: parse directly without invoking python
        if [[ -n "$VIRTUAL_ENV" ]] && [[ -f "$VIRTUAL_ENV/pyvenv.cfg" ]]; then
            # Read python version from venv config (faster than invoking python)
            while IFS= read -r line; do
                if [[ $line == version* ]]; then
                    py_version="${line#*= }"
                    IFS='.' read -r py_major py_minor py_patch _ <<< "$py_version"
                    break
                fi
            done < "$VIRTUAL_ENV/pyvenv.cfg"
        else
            # Only invoke python if we really need to
            read -r py_major py_minor py_patch < <(python -c 'import sys; v=sys.version_info; print(f"{v.major} {v.minor} {v.micro}")' 2>/dev/null || echo "0 0 0")
        fi

        # Get pyenv information (only if PYENV_SHELL is set)
        if [[ -n "$PYENV_SHELL" ]]; then
            # Cache pyenv version-name (expensive operation)
            if [[ -z "$_CACHED_PYENV_VERSION" ]] || ! pyenv version-name &>/dev/null; then
                _CACHED_PYENV_VERSION="$(command pyenv version-name 2>/dev/null)"
                _CACHED_PYENV_ORIGIN="$(command pyenv version-origin 2>/dev/null)"
            fi

            pyenv_version="$_CACHED_PYENV_VERSION"
            pyenv_origin="$_CACHED_PYENV_ORIGIN"

            # Simplify path replacements
            if [[ -n "$git_root_dir" ]]; then
                pyenv_origin="${pyenv_origin#"$git_root_dir"/}"
            fi
            pyenv_origin="${pyenv_origin/#"$HOME"/\~}"

            # Extract major.minor from pyenv version (faster string manipulation)
            IFS='.' read -r pyenv_major pyenv_minor pyenv_patch _ <<< "$pyenv_version"

            if [[ "$py_major.$py_minor.$py_patch" == "$pyenv_major.$pyenv_minor.$pyenv_patch" ]]; then
                pyenv_info="${__Reset}${__Blue}${pyenv_origin}:${__Bold}${pyenv_major}.${pyenv_minor}"
            else
                out_info="$__BlueLight(${__Bold}$py_major.$py_minor.$py_patch$__ResetBold|"
                pyenv_info="${__Reset}${__Red}${pyenv_origin}:${__Bold}${pyenv_version}"
            fi
        fi

        # Get virtualenv information (only if VIRTUAL_ENV is set)
        if [[ -n "$VIRTUAL_ENV" ]]; then
            venv_origin="$VIRTUAL_ENV"
            if [[ -n "$git_root_dir" ]]; then
                venv_origin="${VIRTUAL_ENV#"$git_root_dir"/}"
            fi
            venv_origin="${venv_origin/#"$HOME"/\~}"

            # We already read this earlier for py_version, reuse it
            if [[ -n "$py_version" ]]; then
                IFS='.' read -r venv_major venv_minor venv_patch _ <<< "$py_version"
            elif [[ -f "$VIRTUAL_ENV/pyvenv.cfg" ]]; then
                while IFS= read -r line; do
                    if [[ $line == version* ]]; then
                        venv_version="${line#*= }"
                        IFS='.' read -r venv_major venv_minor venv_patch _ <<< "$venv_version"
                        break
                    fi
                done < "$VIRTUAL_ENV/pyvenv.cfg"
            fi

            if [[ "$py_major.$py_minor.$py_patch" == "$venv_major.$venv_minor.$venv_patch" ]]; then
                venv_info="${__Reset}${__BlueLight}${venv_origin}${__Bold}:${venv_major}.${venv_minor}"
            else
                out_info="$__BlueLight(${__Bold}$py_major.$py_minor.$py_patch$__ResetBold|"
                venv_info="${__Reset}${__Red}${venv_origin}:${__Bold}${venv_major}.${venv_minor}.${venv_patch}"
            fi
        fi

        # Build final output
        if [[ -n "$pyenv_info" && -n "$venv_info" ]]; then
            out_info="$out_info${pyenv_info}$__BlueLight|${__Reset}${venv_info}$__BlueLight)${__Reset}"
        elif [[ -n "$pyenv_info" ]]; then
            out_info="$out_info${pyenv_info}$__BlueLight)$__Reset"
        elif [[ -n "$venv_info" ]]; then
            out_info="$out_info${venv_info}$__BlueLight)$__Reset"
        else
            return  # Don't print anything if no python env
        fi

        echo "$out_info"
    }

    function pip() {
        local cmd="$1"

        if _e "pipman" && [[ "$cmd" == "install" && -z "$VIRTUAL_ENV" ]]; then
            shift

            local params=()  # I seriously hate bash
            for param in "$@"; do
                if [[ "$param" != "--break-system-packages" ]]; then
                    params+=("$param")
                fi
            done

            mkdir -p "$HOME/.pipman"
            echo -e '\e[01;93mCreating PKGBUILDs...\e[00m'
            pipman -t "$HOME/.pipman" -S "${params[@]}"
        else
            command pip "$@"
        fi
    }

    function venv() {
        local python_version python_executable

        # Check if pyenv is available
        if ! _e "pyenv"; then
            echo "pyenv is not available. Creating venv with system python..."
            python3 -m venv .venv
            source .venv/bin/activate
            return
        fi

        # If an argument is provided, use it as the python version
        if [[ $# -eq 1 ]]; then
            python_version="$1"
        else
            # Get available python versions from pyenv
            local versions=()
            readarray -t versions < <(pyenv versions --bare | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)

            if [[ ${#versions[@]} -eq 0 ]]; then
                echo "No Python versions found in pyenv. Install one with: pyenv install <version>"
                return 1
            fi

            echo "Available Python versions:"
            select_option "${versions[@]}" "Type custom version"
            local choice=$?

            if [[ $choice -eq $((${#versions[@]})) ]]; then
                # User chose to type custom version
                echo -n "Enter Python version: "
                read -r python_version
            else
                python_version="${versions[$choice]}"
            fi
        fi

        # Check if the specified version is installed
        if ! pyenv versions --bare | grep -q "^${python_version}$"; then
            echo "Python $python_version is not installed. Installing..."
            if ! pyenv install "$python_version"; then
                echo "Failed to install Python $python_version"
                return 1
            fi
        fi

        # Get the python executable path
        python_executable="$(pyenv prefix "$python_version")/bin/python"

        if [[ ! -x "$python_executable" ]]; then
            echo "Python executable not found at $python_executable"
            return 1
        fi

        echo "Creating virtual environment with Python $python_version..."

        # Remove existing .venv if it exists
        if [[ -d ".venv" ]]; then
            echo "Removing existing .venv directory..."
            rm -rf .venv
        fi

        # Create the virtual environment
        if "$python_executable" -m venv .venv; then
            echo "Virtual environment created successfully."
            echo "Activating virtual environment..."
            source .venv/bin/activate
            echo "Virtual environment activated. Python version: $(python --version)"
        else
            echo "Failed to create virtual environment"
            return 1
        fi
    }
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

##  +-+-+-+-+-+-+
##  |c|u|s|t|o|m|
##  +-+-+-+-+-+-+
if [[ -f "$HOME/.bash_custom" ]]; then
    source "$HOME/.bash_custom"
fi
