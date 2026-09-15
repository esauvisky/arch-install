#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

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

function _pre_command() {
    # Fast ignore certain commands using case (glob patterns are faster than regex)
    case "$BASH_COMMAND" in
        echo*|printf*|cd*|ls*|_set_prompt*|__vte_prompt_command*|$'\033'*) return ;;
    esac

    # Only fetch history if we'll use it
    local history_entry current_cmd
    history_entry="$(HISTTIMEFORMAT='' history 1 2>/dev/null)"
    current_cmd="${history_entry#*[0-9] }"

    # Additional filtering on actual command
    case "$current_cmd" in
        echo*|printf*|cd*|ls*|_set_prompt*|__vte_prompt_command*) return ;;
    esac

    # Set terminal title
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

##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
##  |V|T|E| |P|r|o|m|p|t| |C|a|c|h|i|n|g|
##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Cache VTE prompt command updates to reduce overhead
_VTE_LAST_PWD=""
_VTE_LAST_UPDATE=0

function __vte_prompt_command_cached() {
    # Skip if not in VTE terminal
    [[ -n "$VTE_VERSION" ]] || return 0

    # Only update if PWD changed or cache expired
    local current_time
    current_time=$(date +%s)

    if [[ "$_VTE_LAST_PWD" != "$PWD" ]] ||
       [[ $((current_time - _VTE_LAST_UPDATE)) -gt $_VTE_CACHE_TTL ]]; then
        __vte_prompt_command
        _VTE_LAST_PWD="$PWD"
        _VTE_LAST_UPDATE=$current_time
    fi
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
    PROMPT_COMMAND='_set_prompt; __vte_prompt_command_cached'
else
    PROMPT_COMMAND='_set_prompt'
fi
