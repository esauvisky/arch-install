#!/usr/bin/env bash
##############################################
######### Author: emi~ (@esauvisky) ##########
## THIS IS CERTAINLY NOT POSIX COMPATIBLE!! ##
##############################################
###### Also requires bash 4.4 or higher ######

## Uncomment the following line for debugging this file
# PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace

########################
# BASH ETERNAL HISTORY #
########################
## Author: emi et al., took ages to figure something that worked.
# Change the file location because certain bash sessions truncate .bash_history file upon close:
export HISTFILE=~/.bash_eternal_history
# Maximum number of entries on the current session (nothing is infinite):
export HISTSIZE=5000000
# Maximum number of lines in HISTFILE (nothing is infinite).
export HISTFILESIZE=10000000
# Commands to ignore and skip saving
export HISTIGNORE="clear:exit:history:ls"
# Ignores dupes and deletes old ones (latest doesn't work _quite_ properly, but does the trick)
export HISTCONTROL=ignoredups:erasedups
# Custom history time prefix format
export HISTTIMEFORMAT='[%F %T] '
# Writes multiline commands on the history as one line
shopt -s cmdhist
# ESSENTIAL: appends to the history at each command instead of writing everything when the shell exits.
shopt -s histappend
# Do not enable this or it's gonna duplicate the last command if it's multiline
# shopt -s lithist

# Erases history dups on EXIT
function historymerge {
    history -n; history -w; history -c; history -r;
}
trap historymerge EXIT


##################
# AUTOCOMPLETION #
##################
## Tip: Autocompletion for custom funcs without writing our own completion function
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
    # the STDERR redirection is to not print an annoying bug on
    # GCP VMs that make sed error out for some stupid reason and bad coding
    source /usr/share/bash-completion/completions/git #2>/dev/null
fi

#################
#    is_ssh     #
#################
# Returns if the current shell is running inside a SSH
# Works with sudo su, also works if running local sshd.
# Taken from: https://unix.stackexchange.com/a/12761
_HOSTNAME="$(hostname -f)"
function is_ssh() {
  p=${1:-$PPID}
  read pid name x ppid y < <( cat /proc/$p/stat )
  # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p)
  [[ "$name" =~ sshd ]] && { return 0; }
  [ "$ppid" -le 1 ]     && { return 1; }
  is_ssh $ppid
}

#################
# select_option #
#################
# Amazing bash-only menu selector
# Taken from http://tinyurl.com/y5vgfon7
# Further edits by @emi
function select_option() {
    ESC=$(printf "\033")
    cursor_blink_on() { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to() { printf "$ESC[$1;${2:-1}H"; }
    print_option() { printf "   $1 "; }
    print_selected() { printf "  $ESC[7m $1 $ESC[27m"; }
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
                break ;;
            up)
                ((selected--))
                if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi ;;
            down)
                ((selected++))
                if [ $selected -ge $# ]; then selected=0; fi ;;
        esac
    done
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on
    trap - SIGINT
    return $selected
}

###########
# Extract #
###########
# Extracts anything
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



###########
# magicCD #
###########
# Searches for directories recursively and cds into them
# Usage:
#   alias ALIAS_NAME='_magicCD DIR_DEPTH BASE_DIR
# Where DIR_DEPTH is how many nested directories from
# within BASE_DIR to recursively search into.
# Author: emi~
]
# Example:
# Suppose you have this structure:
# - ~/Coding/
#   - Projects/
#       - project_1/
#       - project_2/
#       - foo/
#   - Personal/
#      - secret_self_bot/
#      - wip_project/
#
# If you add to this file,
#   alias cdp='_magicCD 2 $HOME/Coding/'
# then if you run,
# cdp: will send you to ~/Coding/
# cdp proj: will show you a selector with all the dirs containing 'proj',
#           i.e.: ~/Coding/Projects/project_1 and 2 and wip_project from Personal
# cdp wip: will directly send you to the only dir containing 'wip'
#           i.e.: ~/Coding/Projects/wip_project
function _magicCD() {
    if [[ ! -d "$2" && ! "$1" -ge 2 ]]; then
        echo "Error in the syntax."
        return 1
    fi


    __MAGIC_CD_DIR="${2}"
    __DEPTH="${1}"
    shift
    shift

    if [[ -d "${1}" ]]; then
        cd "${1}"
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

###############
# Quick Spawn #
###############
# Spawns a process and closes the terminal, without killing the process.
# Author: emi~
function e() {
    if [ -x "$(command -v "${1}")" ] || alias "${1}" >&/dev/null; then
        eval "${@}" &
        disown
        exit 0
    else
        echo "Error: ${1} is not installed." >&2
        exit 1
    fi
}
# Adds list of completions to e() (basically adds every executable)
complete -W "$(compgen -c)" -o bashdefault -o default 'e'

#############
# FIND DIRS #
#############
# Finds directories recursively, and shows select_option
# afterwards if less than 20 results.
function findir() {
    readarray -d '' results < <(find . -type d -iname \*"${1}"\* -print0)

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

###################
## COLORS, LOTS! ##
###################
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

if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    _COLOR_ALWAYS_ARG='--color=always'
fi

if hash "grc" >&/dev/null; then
    if [[ -f /etc/profile.d/grc.bashrc ]]; then
        source /etc/profile.d/grc.bashrc >&/dev/null # grc/colourify
        if alias colourify >&/dev/null; then
            # enables colourify dinamycally, if the above
            # didn't fail for some reason
            _COLOURIFY_CMD='colourify'
        else
            _COLOURIFY_CMD='grc'
        fi
    else
        _COLOURIFY_CMD='grc'
    fi
fi

###########
# Aliases #
###########

## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '

## Navigation
alias mkdir="mkdir -p"
alias go="xdg-open"
alias ls="${_COLOURIFY_CMD} ls -ltr --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"
alias grep="grep -n -C 2 $_COLOR_ALWAYS_ARG -E"

# Makes diff decent
if hash colordiff >&/dev/null; then
    alias diff="colordiff -B -U 5 --suppress-common-lines"
else
    alias diff="diff $_COLOR_ALWAYS_ARG -B -U 5 --suppress-common-lines"
fi

## Logging
alias watch="watch --color -n0.5"
# Makes dmesg timestamps readable
alias dmesg='dmesg --time-format ctime'
# Makes dd pretty
alias dd="dd status=progress oflag=sync"
# Makes df pretty
alias df="${_COLOURIFY_CMD} df -H"

# Btrfs aliases for usage and df
if hash "btrfs" >&/dev/null; then
    alias bdf="grc -c ~/.local/share/grc/conf.btrfs sudo btrfs filesystem df /"
    alias busage="grc -c ~/.local/share/grc/conf.btrfs sudo btrfs filesystem usage -H /"
fi

# Makes ccze not stupid (fast and no output clearing)
if hash "ccze" >&/dev/null; then
    alias ccze='ccze -A -o nolookups'
fi

# journalctl handy aliases
if hash "journalctl" >&/dev/null; then
    alias je='journalctl -efn 50 -o short --no-hostname | \ccze -A'
    alias jb='journalctl -eb -o short --no-hostname'

    # alias js='journalctl -lx _SYSTEMD_UNIT='
    # function js() {
    #     if [[ $# -eq 0 ]]; then
    #         echo -e 'js is a handy script to monitor systemd logs in real time,\nmany orders of magnitude better than using systemctl status.'
    #         echo -e "Usage:\n\t$0 SYSTEMD_UNIT"
    #     fi
    #     journalctl -lx _SYSTEMD_UNIT="${1}"
    # }
    # TODO: autocomplete js

fi

## Git
if hash "git" >&/dev/null; then
    # alias gitl='git log --all --decorate=full --oneline'
    alias gitl="git log --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"
    alias gits='git status'

    alias gitcam='git commit -a -m '
    function gitcleanbranches() {
        git fetch --prune
        git checkout master
        for r in $(git for-each-ref refs/heads --format='%(refname:short)'); do
            if [[ "$(git merge-base master "$r")" == "$(git rev-parse --verify "$r")" ]]; then
                if [ "$r" != "master" ]; then
                    git branch --delete "$r"
                fi
            fi
        done
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
    # Autocomplete local branches only
    function _git_local_branches() {
        __gitcomp_direct "$(__git_heads)"
    }
    __git_complete gitdelbranch _git_local_branches
fi

## Systemctl
if hash "systemctl" >&/dev/null; then
    alias start="systemctl start"
    alias stop="systemctl stop"
    alias restart="systemctl restart"
    alias st="systemctl status -n9999 --no-legend -a -l"
    complete -F _complete_alias start
    complete -F _complete_alias stop
    complete -F _complete_alias restart
    complete -F _complete_alias st
fi

## Pacman
if hash "pacman" >&/dev/null; then
    alias pacman="pacman "
    alias pacs="sudo pacman -S --needed --asdeps"
    alias pacr="sudo pacman -R"
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
            echo "$currentUpdatePkgs" > "$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)"
        fi

        echo -e "\e[01;91m\nUpdating pacman packages...\e[00m"
        sudo \pacman -Su --noconfirm
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

# Pretty colorful and super verbose logcat for adb devices
if hash "adb" >&/dev/null; then
    alias logcat="adb logcat -b all -v color,usec,uid"
fi

# Sets default stuff for bat
if hash "bat" >&/dev/null; then
    export BAT_THEME="Monokai Extended Bright"
    alias bat="bat --italic-text=always --decorations=always --color=always"
fi

## True screen clearing
function clear() {
    echo -en "\033c"
}

###################################
# The Divine and Beautiful Prompt #
###################################
## Install 'fortune', 'cowsay' and 'lolcat' and have fun every time you open up a terminal.
[[ "$PS1" ]] && hash "fortune" "cowthink" "lolcat" >&/dev/null && fortune -s -n 200 | cowthink | lolcat -F 0.1 -p 30 -S 1

## Formats seconds into more pretty H:M:S
## Stolen from: https://bit.ly/3nJQFwp
function format-duration() {
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

###########################################
# TODO: find some shit that actually wrks #
###########################################
## BASH PREEXEC
## Adds zsh-like preexec and precmd support to bash
## @see https://github.com/rcaloras/bash-preexec/
## **Must be the last thing to be imported!**
# if [[ -f "$HOME/.bash_preexec" ]]; then
#     source "$HOME/.bash_preexec"
# fi

# ## Adds the time it took the cmd to run
# function preexec() {
#     if [[ "UNSET" == "${timer}" ]]; then
#         timer=$SECONDS
#     else
#         timer=${timer:-$SECONDS}
#     fi
# }
# function precmd() {
#     if [[ "UNSET" == "${timer}" ]]; then
#         timer_show="0s"
#     else
#         the_seconds=$((SECONDS - timer))
#         timer_show="$(format-duration seconds $the_seconds)"
#     fi
#     timer="UNSET"
# }
## Returns a truncated $PWD depending on window width
function _get_truncated_pwd() {
    local tilde="~"
    local newPWD="${PWD/#${HOME}/${tilde}}"
    local pwdmaxlen="$((${COLUMNS:-80} / 3))"
    [[ "${#newPWD}" -gt "${pwdmaxlen}" ]] && newPWD="…${newPWD:3-$pwdmaxlen}"
    echo -n "${newPWD}"
}

## Lets disable the embedded venv prompt and make our own :)
export VIRTUAL_ENV_DISABLE_PROMPT=0
function _virtualenv_info() {
    [[ -n "$VIRTUAL_ENV" ]] && echo "${VIRTUAL_ENV##*/}"
}

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
    history -n
    # Not working crazy shit that's supposed to actually erase previous dups (https://goo.gl/DXAcPO)
    # history -n; history -w; history -c; history -r;

    # Colors
    local Blue='\[\e[01;34m\]'
    local Bluelly='\[\e[38;5;31;1m\]'
    local White='\[\e[01;37m\]'
    local Violet='\[\e[01;35m\]'
    local Magenta='\[\e[01;36m\]'
    local Red='\[\e[01;31m\]'
    local Green='\[\e[01;32m\]'
    local GreenLight='\[\e[01;92m\]'
    local YellowLight='\[\e[01;93m\]'
    local VioletLight='\[\e[01;95m\]'
    local PinkLight='\[\e[00;91m\]'
    local GrayBold='\[\e[01;98m\]'
    local GrayBackground='\[\e[01;40m\]'
    # 1337 users get different colors
    # a.k.a: warns if you're in a root shell

    # TODO: fix this shit, do not set the color according to the user
    #       actually, set global colors to be used all along this file
    if [ $(id -u) -eq 0 ]; then
        local YellowB='\[\e[01;31m\]'
        local YellowN='\[\e[00;31m\]'
    else
        local YellowB='\[\e[01;33m\]'
        local YellowN='\[\e[00;33m\]'
    fi

    local Reset='\[\e[00m\]'
    local FancyX='\342\234\227'
    local Checkmark='\342\234\223'

    # Prints  ---\n\n after previous command without spawning
    # a newline after it, so you can actually easily notice
    # if it's output has an EOF linebreak.
    PS1="$YellowN---$Reset\\n\\n"

    if [[ $_last_command == 0 ]]; then
        # If last cmd didn't return an error (exit code == 0)
        PS1+="$Green$Checkmark ${White}000 "
        if is_ssh; then
            PS1+="$YellowB\\u@$_HOSTNAME"
        else
            PS1+="$Green\\u@\\h"
        fi
    else
        PS1+="$Red$FancyX $White$(printf "%03d" $_last_command) "
        if is_ssh; then
            PS1+="$YellowB\\u@$_HOSTNAME"
        else
            PS1+="$Red\\u@\\h"
        fi
    fi

    ## Nicely shows you're in a python virtual environment
    if [[ -n $VIRTUAL_ENV ]]; then
        PS1+=" $Magenta(venv:$(_virtualenv_info))"
    fi

    ## Nicely shows you're in a git repository
    # TODO: @see: /usr/share/git/git-prompt.sh for more use cases and
    # more robust implementations.
    # FIXME: **this is slow**. depending on what you're doing, it might
    # hang when inside dirs of big projects (3gb+)
    repo_info="$(git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --short HEAD 2>/dev/null)"
    rev_parse_exit_code="$?"

    if [[ -n $repo_info ]]; then
        if [ "$rev_parse_exit_code" = "0" ]; then
            short_sha="${repo_info##*$'\n'}"
            repo_info="${repo_info%$'\n'*}"
        fi
        branch_name=$(git symbolic-ref -q HEAD)
        branch_name=${branch_name##refs/heads/}
        branch_name=${branch_name:-$short_sha}

        PS1+=" ${Violet}["

        local -r git_status=$(git status 2>&1)  # TODO: still couldn't find what -r is about
                                                # see: https://github.com/koalaman/shellcheck/wiki/SC2155)
        if echo "${git_status}" | grep -qm1 'nothing to commit'; then
            if [[ $branch_name == "$short_sha" ]]; then
                PS1+="${GrayBackground}${White}• $branch_name•$Reset" # DETACHED HEAD
            else
                PS1+="$GreenLight✔ $branch_name•$Reset"
            fi
        elif echo "${git_status}" | grep -qm1 'Changes not staged'; then
            PS1+="$YellowB→ $branch_name!$Reset"
        elif echo "${git_status}" | grep -qm1 'Changes to be committed'; then
            PS1+="$Violet→ $branch_name+$Reset"
        else
            PS1+="$Blue→ $branch_name*$Reset"
        fi
        if echo "${git_status}" | grep -qm1 'Untracked files'; then
            PS1+="$GrayBold?$Reset"
        fi
        PS1+="$Violet]$Reset"
    fi

    PS1+=" $Bluelly\\w\\n$YellowB\\\$ $YellowN"

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
    PS1RHS_stripped=$(sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" <<<"$PS1RHS")

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

########################
# BUG FIXES AND TWEAKS #
########################
## vte.sh
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

## GPG Signing TTY
## I don't recall why but this is required for GPG signing in git
GPG_TTY=$(tty)
export GPG_TTY

## This fixes a bug that happens when `sudo su USER`
## inside a SSH shell that keeps loginctl envvars
## making some commands not work.
## @see: https://unix.stackexchange.com/questions/346841/why-does-sudo-i-not-set-xdg-runtime-dir-for-the-target-user
if [[ -z $XDG_RUNTIME_DIR && $(is_ssh) ]]; then
    export XDG_RUNTIME_DIR=/run/user/$UID
fi

## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1

## Sets default EDITOR environment variable
## If logged as root or in a ssh shell uses only term editors.
if [[ -n $DISPLAY && ! $EUID -eq 0 && ! $(is_ssh) ]]; then
    for editor in "subl3" "gedit"; do
        if hash "$editor" >&/dev/null; then
            export EDITOR=$editor
            break
        else
            continue
        fi
        export EDITOR="vi"
    done
else
    if hash "nano" >&/dev/null; then
        export EDITOR="nano"
    else
        export EDITOR="vi"
    fi
fi

## Adds alias autocompletion for **all** the aliases that
## did not had it manually added using _complete_alias.
## This is called after all aliases are defined before the prompt block.
while read -r i; do
    _alias=$(echo "$i" | sed -E 's/alias ([^=]+)=.+/\1/')
    if ! complete -p "$_alias" >&/dev/null; then
        complete -F _complete_alias "$_alias"
    fi
done < <(alias -p)


################
# CUSTOM STUFF #
################
if [[ -f "$HOME/.bash_custom" ]]; then
    source "$HOME/.bash_custom"
fi
