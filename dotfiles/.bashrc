#!/usr/bin/env bash
##############################################
######### Author: emi~ (@esauvisky) ##########
## THIS IS CERTAINLY NOT POSIX COMPATIBLE!! ##
##############################################
###### Also requires bash 4.4 or higher ######

## Perf. optimization: https://stackoverflow.com/questions/18039751/how-to-debug-a-bash-script-and-get-execution-time-per-command
## Uncomment one of the following line for debugging this file
# PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
# N=`date +%s%N`; export PS4='+[$(((`date +%s%N`-$N)/1000000))ms][${BASH_SOURCE}:${LINENO}]: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'; set -x;

[[ $- != *i* ]] && return

####################
## (some) Configs ##
####################
# android shit (mostly for arch/manjaro)
if [[ -d /opt/android-ndk ]]; then
    export ANDROID_NDK_ROOT="/opt/android-ndk" # the proper one
    export ANDROID_NDK_HOME="/opt/android-ndk" # uncommon
    export ANDROID_NDK="/opt/android-ndk"      # uncommon

    # adds build tools (aapt, dexdump, etc)
    # only adds the highest version
    build_tools="$(find "$ANDROID_HOME/build-tools" -maxdepth 1 -type d | sort --numeric-sort --reverse | head -n1)"
    if [[ -d "$build_tools" ]]; then
        export PATH="$PATH:$build_tools"
    fi
fi

if [[ -d ~/.local/bin ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# List of places to show when using 'cdcool [arg]'
cool_places=(
    "~/.local/share/gnome-shell/extensions"
    "~/.local/share/applications"
    "~/.config/systemd/user/"
    "/etc/systemd/user/"
    "/var/lib/docker/volumes"
    "/usr/share/bash-completion/completions"
)

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
# FIXME: Writes multiline commands on the history as one line
# TODO: TESTING!!!
# Actually writes multiline commands on the history AS MULTIPLE LINES!
# If something breaks, write down what was and restore backup from
# ~/.bash_eternal_history~ (jan 7 2021)
shopt -s cmdhist
shopt -s lithist
# ESSENTIAL: appends to the history at each command instead of writing everything when the shell exits.
shopt -s histappend
# Erases history dups on EXIT
# function historymerge() {
#     history -n
#     history -w
#     history -c
#     history -r
# }
# trap historymerge EXIT

##################
# AUTOCOMPLETION #
##################
## Tip: Autocompletion for custom funcs without writing our own completion function
# 1. Type the command, and press <Tab> to autocomplete
# 2. Run `complete -p command`
# 3. The output is the hook that was used to complete it.
# 4. Change it accordingly to apply it to your function.
## Loads bash's system-wide installed completions
## Loads gits completion file for our custom completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    # the STDERR redirection is to not print an annoying bug on
    # GCP VMs that make sed error out for some stupid reason and bad coding
    source /usr/share/bash-completion/completions/git #2>/dev/null
fi
# if [[ -f /usr/share/bash-completion/bash_completion ]]; then
#     source /usr/share/bash-completion/bash_completion
# fi

#################
#    is_ssh     #
#################
# Returns if the current shell is running inside a SSH
# Works with sudo su, also works if running local sshd.
# Taken from: https://unix.stackexchange.com/a/12761
function is_ssh() {
    # windows or other weird system:
    if [[ ! -f /proc/1/stat ]]; then
        return 0
    fi
    p=${1:-$PPID}
    read pid name x ppid y < <(cat /proc/$p/stat)
    # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p)
    [[ "$name" =~ sshd ]] && { return 0; }
    [ "$ppid" -le 1 ] && { return 1; }
    is_ssh $ppid
}

##############
# url_decode #
##############
function urldecode() {
    : "${*//+/ }"
    echo -e "${_//%/\\x}"
}

#################
# select_option #
#################
# Amazing bash-only menu selector
# Taken from http://tinyurl.com/y5vgfon7
# Further edits by @emi
function select_option() {
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

###################
# history grepper #
###################
# Fancy way of grepping history, think of it
# as an improved Ctrl+R that supports regex
function h() {
    # Workaround for the lack of
    # multidimensional arrays in bash.
    local results_cmds=()
    local results_nums=()
    local query="${@}"

    readarray -d '' grepped_history < <(history | \grep -ZE -- "$query")
    while read -r entry; do
        local number="${entry// */}"
        local datetime="${entry#*[}"
        datetime="${datetime%] *}"
        local cmd="${entry##$number*$datetime] }"
        # Strips repeated results
        if [[ ! "${results_cmds[*]}" =~ $cmd ]]; then
            results_cmds+=("$cmd")
            results_nums+=("$number")
        fi
    done < <(echo "${grepped_history[@]}")

    local string
    for r in "${!results_cmds[@]}"; do
        cmd=$(echo "${results_cmds[$r]}" | \grep -E --color=always "$query")
        line="\e[01;96m${results_nums[$r]} \e[00m$cmd\e[00m"
        printf "$line\n"
    done
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
#
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

#############
# FIND DIRS #
#############
# Finds directories recursively, and shows select_option
# afterwards if less than 20 results.
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

##########
# cdcool #
##########
# This shows a selector to quickly change
# cd into commonly used, hard-to-type directories,
# changing to a su prompt if the user doesn't have
# reading permissions as well.
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

    final_path="${cool_places[$selected_index]/#\~/$HOME}"

    if [[ ! -d "$final_path" ]]; then
        echo "The selected path does not exist. Fix your script." && return 1
    elif ! test -r "$final_path"; then
        echo -n "No read permissions for $final_path! "
        sudo su root sh -c "cd $final_path; bash" # don't ask, just don't.
    else
        cd "$final_path" || return 1
    fi
}

###########
# SAFE RM #
###########
## Safe rm using gio trash
## Falls back to rm in any unsupported case
## Only caveat: ignores -r as gio trash already
## does it recursively, without option.
if hash gio >&/dev/null; then
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

#################
# COLORS, LOTS! #
#################
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
    if [[ -f ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    _COLOR_ALWAYS_ARG='--color=always' # FIXME: makes no sense for this to be inside this block
fi
# GRC
if hash "grc" >&/dev/null; then
    GRC='grc -es'
    if [[ -f /etc/profile.d/grc.sh ]]; then
        source /etc/profile.d/grc.sh >&/dev/null
    fi
    alias cat="$GRC cat"
fi

## Pretty hostname
_HOSTNAME="$(hostname -f)"
_HOSTNAME=${_HOSTNAME%.*}
_HOSTNAME=${_HOSTNAME//.*./}

###########
# Aliases #
###########

## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '

## Navigation
alias ls="${GRC} ls -ltr --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"
alias go="xdg-open"
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
alias df="${GRC} df -H"
# Makes dd pretty
alias dd="dd status=progress oflag=sync"
# Makes df$GRC

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
    alias je='journalctl -efn 50 -o short --no-hostname'
    alias jb='journalctl -eb -o short --no-hostname'
    complete -F _journalctl je
    complete -F _journalctl jb
    # alias js='journalctl -lx _SYSTEMD_UNIT='
    function js() {
        if [[ $# -eq 0 ]]; then
            echo -e 'js is a handy script to monitor systemd logs in real time,\nmany orders of magnitude better than using systemctl status.'
            echo -e "Usage:\n\t$0 SYSTEMD_UNIT"
        fi
        # TODO: autocomplete js
        journalctl -lx _SYSTEMD_UNIT="${1}"
    }

fi

## Git
if hash "git" >&/dev/null; then
    # alias gitl='git log --all --decorate=full --oneline'
    alias gitl="git log --graph --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"
    alias gitw="git log --no-merges --pretty=format:'------------> %C(bold red)%h%Creset -%C(bold yellow)%d%C(bold white) %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -p"
    alias gits='git status'
    alias gitm='git commit --amend -m '

    alias gitcam='git commit -a -m '

    function gitc {
        git clone $1 && cd $(basename $1 .git)
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

    # Nicer version of git pull
    # - Deletes all local branches that were merged and deleted from the remote.
    # - Makes local branches without remote counterparts track them in case it's possible.
    # - Updates/syncs all local branches with their remote counterpart, not only the current checked-out one.
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
                            echo -e "   ${fblu}Branch ${bold}$LB${end}${fblu} was ${bold}$NBEHIND${end}${fblu} commit(s) behind of ${bold}$REMOTE/$RB${end}${fblu}. Fast-forward merge.${end}"
                            git merge -q $ARB
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

# Pretty colorful and super verbose logcat for adb devices
if hash "adb" >&/dev/null; then
    alias logcat_5min="adb logcat -v color,usec,uid -d -t \"\$(date \"+%F %T.000\" --date=\"5 minutes ago\")\""
    alias logcat_live="adb logcat -T1 -v color,usec,uid"
    alias logcat_giant="adb logcat -b all -v color,usec,uid"
    alias adl="adb devices -l | sed -E 's/([^ ]+) +device .+device:(.+) transport_id:([0-9]+)/TID:\3\tserial:\1\tdevice:\2/' | grcat .grc/conf.netstat"
    alias adt="adb -t "
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

## Returns a truncated $PWD depending on window width
function _get_truncated_pwd() {
    local tilde="~"
    local newPWD="${PWD/#${HOME}/${tilde}}"
    local pwdmaxlen="$((${COLUMNS:-80} / 4))"
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
    # history -n
    # Not working crazy shit that's supposed to actually erase previous dups (https://goo.gl/DXAcPO)
    # history -n; history -w; history -c; history -r;

    # Colors
    local Blue='\[\e[01;34m\]'
    local Bluelly='\[\e[38;5;31;1m\]'
    local White='\[\e[01;37m\]'
    local Violet='\[\e[01;35m\]'
    local Magenta='\[\e[01;36m\]'
    local Red='\[\e[00;31m\]'
    local RedBold='\[\e[01;31m\]'
    local Green='\[\e[00;32m\]'
    local GreenBold='\[\e[01;32m\]'
    local GreenLight='\[\e[01;92m\]'
    local YellowLight='\[\e[01;93m\]'
    local VioletLight='\[\e[01;95m\]'
    local PinkLight='\[\e[00;91m\]'
    local GrayBold='\[\e[01;98m\]'
    local GrayBackground='\[\e[01;40m\]'
    local Yellow='\[\e[00;33m\]'
    local YellowBold='\[\e[01;33m\]'
    # 1337 users get different colors
    # a.k.a: warns if you're in a root shell

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
        PS1+="$GreenBold$Checkmark ${White}000 "
        PS1+="$GreenBold\\u${__cHost}@${_HOSTNAME}"
    else
        PS1+="$RedBold$FancyX ${White}$(printf "%03d" $_last_command) "
        PS1+="$RedBold\\u${__cHost}@${_HOSTNAME}"
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

        # TODO: stop using git status here, it lags like fuck when
        #       lots of files are deleted
        local -r git_status=$(git status 2>&1) # TODO: still couldn't find what -r is about
        # see: https://github.com/koalaman/shellcheck/wiki/SC2155)
        if echo "${git_status}" | grep -qm1 'nothing to commit'; then
            if [[ $branch_name == "$short_sha" ]]; then
                PS1+="${GrayBackground}${White}• $branch_name•$Reset" # DETACHED HEAD
            else
                PS1+="$GreenLight✔ $branch_name•$Reset"
            fi
        elif echo "${git_status}" | grep -qm1 'Changes not staged'; then
            PS1+="$YellowBold→ $branch_name!$Reset"
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

    # Sets the prompt color according to
    # user (if logged in as root gets red)
    if [[ $(id -u) -eq 0 ]]; then
        PS1+=" $Bluelly\\w\\n${RedBold}\\\$ ${Red}"
    else
        PS1+=" $Bluelly\\w\\n${YellowBold}\\\$ ${Yellow}"
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

## SSH Stuff (runs only if it's inside ssh)
if is_ssh; then
    if [[ $TERM =~ .*kitty.* ]]; then
        export TERM=xterm-256color
    fi
    _HOSTNAME="\[\e[01;33m\]${_HOSTNAME} [SSH]"
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

################
# CUSTOM STUFF #
################
if [[ -f "$HOME/.bash_custom" ]]; then
    source "$HOME/.bash_custom"
fi
