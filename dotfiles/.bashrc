#!/usr/bin/env bash
##############################################
######### Author: emi~ (@esauvisky) ##########
## THIS IS CERTAINLY NOT POSIX COMPATIBLE!! ##
##############################################
###### Also requires bash 4.4 or higher ######


## Don't do anything if not running interactively
[[ $- != *i* ]] && exit

###########
# CONFIGS #
###########
## Replace with your username if you want to run the big block at the end of this file
ENABLE_RANDOM_STUFF='esauvisky'

## Enable for debugging:
# PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'
# set -o xtrace

## Notifies commands that take longer than 60 seconds via notify-send
hash notify-send >&/dev/null && NOTIFY_SLOW_COMMANDS=1

#########################
# Environment Variables #
#########################
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
## Alternatively, install `most` and change PAGER variable
# export PAGER="/usr/bin/most -s"

## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1
## Writes multiline commands on the history as one line
shopt -s cmdhist

## Sets default EDITOR environment variable
## If logged as root use exclusively term editors
if [[ ! -z $DISPLAY && ! $EUID -eq 0 ]]; then
    for editor in "subl3" "gedit"; do
        hash "$editor" >&/dev/null && export EDITOR=$editor && break || continue
        export EDITOR="vi"
    done
else
    if hash "nano" >&/dev/null; then
        export EDITOR="nano"
    else
        export EDITOR="vi"
    fi
fi

##########################
## BASH ETERNAL HISTORY ##
##########################
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
# ESSENTIAL: appends to the history at each command instead of writing everything when the shell exits.
shopt -s histappend

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
    . /usr/share/bash-completion/bash_completion
fi

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

################
## transfer.sh #
################
# Transfer any file to transfer.sh with a couple tweaks.
transfer() {
    if [[ $# -eq 0 ]]; then
        echo -e "No arguments specified.\n\n  Arguments:\n  \t-e: Encrypts file before uploading.\n\n  Usage Examples:\n  \ttransfer /tmp/test.md\n  \tcat /tmp/test.md | transfer test.md\n  \ttransfer -e /tmp/test.md" >&2
        return 1
    fi

    if [[ "$1" == '-e' || "$1" == '--encrypt' ]]; then
        shift
        isEncrypted=1
        tmpUpload=$(mktemp -t upload-XXX)
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')".enc"
        echo "Encrypting file $basefile to $tmpUpload..." >&2
        cat "$1" | gpg -ac -o- >> "$tmpUpload"
    else
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        tmpUpload="$1"
    fi

    tmpResponse=$(mktemp -t transfer-XXX)

    if tty -s; then
        echo "Uploading file $tmpUpload to transfer.sh/$basefile..." >&2
        curl --progress-bar --upload-file "$tmpUpload" "https://transfer.sh/$basefile" >> "$tmpResponse"
    else
        echo "Uploading file $tmpUpload to transfer.sh/$tmpUpload..." >&2
        curl --progress-bar --upload-file "-" "https://transfer.sh/$tmpUpload" >> "$tmpResponse"
    fi

    # Copies URL to clipboard if 'xclip' exists.
    if hash xclip; then cat "$tmpResponse" | xclip -selection clipboard -i; fi
    echo -e '\nTransfer finished! URL was copied '
    cat "$tmpResponse" <(echo)

    if [[ -n $isEncrypted ]]; then
        echo -e "Use gpg -o- to decrypt:\n  $ curl $(cat "$tmpResponse") | gpg -o- > ./${basefile%%.enc}" >&2
    fi
    rm -f "$tmpResponse"
}


#############################
# "SECURE" FTP TLS Transfer #
#############################
## Sets a password via the keyring:
## If you see a dialog when running this, function, run the command below with your credentials:
# python -c "import keyring; keyring.set_password('name', 'username', '$PASSWORD')"
function emibemol_ftp() {
    USER='u373108367'
    HOST='ftp.emibemol.com'
    PASS=$(python -c "import keyring; print(keyring.get_password('${HOST}', '${USER}'))")
    if [[ $# == 1 ]]; then
        TARGET='/public_html'
    elif [[ $# == 2 ]]; then
        TARGET="${2}"
    elif ! hash ncftpput || [[ ! -f "${1}" ]]; then
        echo 'Usage: emibemol_ftp local_file_or_dir [remote_dir]'
        echo
        echo '[remote_dir] defaults to /public_html. You also need ncftp.'
        return 1
    fi

    ncftpput -vRm -u "${USER}" -p "${PASS}" "${HOST}" "${TARGET}" "$1"
    URL="${HOST##ftp\.}/${TARGET%%public_html}/${1##\./}"
    URL="${URL/\/\//}"
    echo "Uploaded to $URL. Copied to clipboard."
    if hash xclip; then echo "$URL" | xclip -selection clipboard -i; fi
}

###########
# magicCD #
###########
# Searches for directories recursively and cds into them.
# Author: emi~
function _magicCD() {
    if [[ ! -d $2 && ! ${1} -ge 2 ]]; then
        echo "Error in the syntax."
        return 1
    fi

    __MAGIC_CD_DIR="${2}"
    __DEPTH="${1}"
    shift
    shift

    # Black magic ;)
    # results=()
    # while IFS=  read -r -d $'\0'; do
    #     results+=("$REPLY")
    # done < <(find "${__MAGIC_CD_DIR}" -depth  -maxdepth 2 -type d -iname \*${*}\* -print0)

    # Neat black magic (bash 4.4 only)
    readarray -d '' results < <(find ${__MAGIC_CD_DIR} -maxdepth ${__DEPTH} -type d -iname \*${*}\* -print0)

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
    readarray -d '' results < <(find . -type d -iname \*${1}\* -print0)

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

##############
# QUICK SUDO #
##############
s() {
    # do sudo, or sudo the last command if no argument given
    if [[ $# == 0 ]]; then
        sudo $(history -p '!!')
    else
        sudo $@
    fi
}

###################
## COLORS, LOTS! ##
###################
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    _COLOR_ALWAYS_ARG='--color=always'
fi

if [[ -f /etc/profile.d/grc.bashrc ]]; then
    source /etc/profile.d/grc.bashrc # grc/colourify
    _COLOURIFY_CMD='colourify'       # enables colourify dinamycally
fi



###########
# Aliases #
###########
## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '

## Navigation
alias clear='_clear'
alias mkdir="mkdir -p"
alias go="xdg-open"
alias ls=$_COLOURIFY_CMD' ls -ltr --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso'

# Makes grep useful
alias grep="grep -n -C 2 $_COLOR_ALWAYS_ARG -E"
# Makes sed useful
alias sed="sed -E"
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
alias dd='dd status=progress oflag=sync'
# Makes ccze not stupid (fast and no output clearing)
alias ccze='ccze -A -o nolookups'
# journalctl handy aliases
if hash "journalctl" >&/dev/null; then
    alias je='journalctl -efn 60 | \ccze -A'
    alias jb='journalctl -b | ccze -A'
fi

## Git
if hash "git" >&/dev/null; then
    # Loads gits completion file for our custom completions
    if [ -f /usr/share/bash-completion/completions/git ]; then
        . /usr/share/bash-completion/completions/git
    fi
    # alias gitl='git log --all --decorate=full --oneline'
    alias gitl="git log --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"
    alias gits='git status'
    alias gitcam='git commit -a -m '
    alias gitcleanbranches='echo "Updating and pruning local copies of remote branches..." && git fetch --prune origin && echo "Removing refs about removed remote branches..." && git remote prune origin'

    function gitdelbranch() {
        # First command deletes local branch, but exits > 0 if not fully merged,
        # so the second command (which deletes the remote branch), will only run
        # if the first one suceeds, making it "safe".
        if [[ $(git symbolic-ref --short -q HEAD) =~ ${@} ]]; then
            echo -e "\E[01mYou should leave the branch you're trying to delete first.\E[0m"
        else
            if ! git branch --delete ${@}; then
                echo "The local repository ${@} does not exist. Do you want to delete the remote one anyway? [y/N]"
                if [[ $(read -r yN) =~ n|N ]]; then
                    echo 'Deleting remote repo'
                    git push origin --delete ${@}
                else
                    echo "Ok, bye!"
                fi
            else
                echo 'Deleting local repo...'
                git branch --delete ${@}
                echo 'Deleting remote repo'
                git push origin --delete ${@}
            fi
        fi
    }
    # Autocomplete local branches only
    function _git_local_branches() {
        __gitcomp_direct "$(__git_heads "" "$cur" " ")"
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
    alias aurss="aurget --sort votes -Ss"
    alias aurs="aurget -S --noconfirm"
    alias pacman="pacman "
    alias pacs="sudo pacman -S --needed --asdeps"
    alias pacr="sudo pacman -R"
    alias pacss="pacman -Ss"
    alias paci="pacman -Qi"
    alias pacl="pacman -Ql"
    alias paccache_safedelete="sudo paccache -r && sudo paccache -ruk1"
    complete -F _complete_alias aurs
    complete -F _complete_alias aurss
    complete -F _complete_alias pacs
    complete -F _complete_alias pacr
    complete -F _complete_alias pacss
    complete -F _complete_alias paci
    complete -F _complete_alias pacl
    complete -F _complete_alias paccache_safedelete

    ## Pacman Awesome Updater
    function pacsyu() {
        echo -e "\e[00;91m\nUpdating pacman repositories...\e[00m"
        sudo \pacman -Sy
        echo -e "\e[00;91m\nSaving log of packages to upgrade...\e[00m"
        mkdir -p "$HOME/.pacman-updated"
        # TODO: add a condition that checks if any of the files inside .pacman-updated already
        #       contains exactly the same packages that pacman -Qu outputs, meaning that
        #       it"s useless to save it again.
        #       Alternatively, save only when the update is finished? Nope. If SIGTERM"d then
        #       no log will be saved, unless we trapped it and ... too much trouble.
        LOG_FILE="$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)"
        \pacman -Qu --color never > "$LOG_FILE"
        echo -e "\e[00;91m\nPress Enter to update pacman packages.\e[00m"
        read
        sudo \pacman -Su --noconfirm
        echo -e "\e[00;91m\nPress Enter to update AUR packages.\e[00m"
        read
        aurget -Syu --noconfirm
        echo -e "\e[00;91m\nPress Enter to update AUR devel packages (e.g.: -git). \e[01mThis will take a long time!\e[00m"
        read
        aurget -Syu --devel --noconfirm
    }

    # Exports the function so every bash process sees it (http://tinyurl.com/y5bnarjm)
    # This way we can call `gnome-terminal -- bash -c 'pacsyu; bash'` and use it in,
    # for example, the 'Arch Linux Updates' gnome extension.
    # export -f pacsyu
    # FIXME: doesn't work, so concatenating it all is the current workaround (watchout for quotes!)... 🙄:
    # gnome-terminal --profile="System Update" -- bash --rcfile /home/esauvisky/.bashrc -c 'echo -e "\e[00;91m\nUpdating pacman repositories...\e[00m";sudo \pacman -Sy;echo -e "\e[00;91m\nSaving log of packages to upgrade...\e[00m";mkdir -p "$HOME/.pacman-updated";LOG_FILE="$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)";\pacman -Qu --color never > "$LOG_FILE";echo -e "\e[00;91m\nPress Enter to update pacman packages.\e[00m";read;sudo \pacman -Su --noconfirm;echo -e "\e[00;91m\nPress Enter to update AUR packages.\e[00m";read;aurget -Syu --noconfirm;echo -e "\e[00;91m\nPress Enter to update AUR devel packages (e.g.: -git). \e[01mThis will take a long time!\e[00m";read;aurget -Syu --devel --noconfirm'

    ## TODO: The Awesome WIP Pacman RollerBack
    function pacman_rollback() {
        echo 'WARNING THIS IS A WIP. CHECK THE SOURCE FIRST AND RUN MANUALLY.'
        return 1
        if [[ -f $1 ]]; then
            while read line; do
                pkg=$(echo "$i" | sed 's/ -> .+//' | sed 's/ /-/')
                echo "Downgrading $pkg"
                sudo pacman --noconfirm --needed -U /var/cache/pacman/pkg/$pkg*
            done < <(cat $1)
        fi
    }

    # Search for outdated packages on AUR
    alias aurcheck="\pacman -Qm | \sed 's/ .*$//' | while read line; do echo -e \"\e[01;37m\$line:\"; aurget -Ss \$line | grep aur\/\$line; read; done"

    # Optimizes pacman stuff (TODO: does it?)
    alias pacfix="sudo pacman-optimize; sudo pacman -Sc; sudo pacman -Syy; echo 'Verificando arquivos de pacotes faltantes no sistema...'; sudo pacman -Qk | grep -v 'Faltando 0'; sudo abs"
fi

if hash adb >&/dev/null; then
    # Pretty colorful and super verbose logcat for adb devices
    alias logcat="adb logcat -b all -v color,usec,uid"
fi


##       Deprecated
## Replaced by bat below
# if hash mdless >&/dev/null; then
#     function md() {
#         if [[ ! -f $1 ]]; then
#             readarray -d '' __md_files < <(find -iname '*.md' -print0)
#             if [[ ${#__md_files[@]} -eq 1 ]]; then
#                 mdless --width $COLUMNS ${__md_files[0]}
#             else
#                 __readme=$(find -iname 'readme.md')
#                 if [[ -f $__readme ]]; then
#                     mdless --width $COLUMNS $__readme
#                 else
#                     echo "There's more than one Markdown file. Please choose one."
#                     return 1
#                 fi
#             fi
#         else
#             mdless --width $COLUMNS $1
#         fi
#     }
#     complete -f -X '!*.md' md
# fi
export BAT_THEME="Monokai Extended Bright"
alias bat="bat --italic-text=always --decorations=always --color=always"


# #################3########
# ## Colorizes Everything ##
# ##########################
# ## FIXME!
# ## This only colourizes commands that
# ## **were not** aliased before, so to
# ## not overwrite them. If you want to
# ## colourize those as well, add it manually.
# ## Author: Emi
# if [[ -n $GRC ]]; then
#     shopt -s nullglob

#     ## This has a problem:
#     # 1 - It's very slow
#     # 2 - Commands with spaces (like `docker info` get merged into dockerinfo)
#     #     so we should grep the conf.dockerinfo file and somehow grab from the regexp
#     readarray -d '\n' _raw_cmds < <(find /usr/local/share/grc/* /usr/share/grc/* $HOME/.grc/* -execdir sh -c 'basename {} | sed -E "s/^conf\.(.+$)/\1/"' \;)

#     shopt -u nullglob

#     for cmd in ${_raw_cmds[@]}; do
#         case "${cmd}" in
#             configure )
#                 alias "${cmd}=colourify ./configure"
#                 ;;
#             docker )
#                 alias docker='colourify docker'
#                 ;;
#             *)
#                 if ! alias "${cmd}" >&/dev/null && hash  "${cmd}" >&/dev/null; then
#                     echo  "${cmd}=colourify ${cmd}.conf"
#                     alias "${cmd}=colourify ${cmd}.conf"
#                 fi
#                 ;;
#         esac
#     done
# fi



############################
# Bottom Padding (DECSTBM) #
############################
# Besides the first couple functions, this attempt
# was a major fail. Any resizing of the window screws things up.

## True screen clearing
function _clear() {
    echo -en "\033c"
}

## Leaves 3 lines of clearance at the bottom of the terminal
function _set_bottom_padding() {
    if $1; then
        echo -e "\n\033[1;$((LINES - 3))r"
    else
        echo -e "\n\033[1;$((LINES - 3))r\033c"
    fi
}
# _set_bottom_padding true

# # FIXME: Tries to fix the padding when resizing the terminal window
# function _fix_bottom_padding() {
#     # Saves current cursor position
#     tput sc

#     # Gets current cursor position
#     echo -en "\E[6n"
#     read -sdR CURPOS
#     CURPOS=${CURPOS#*;}

#     # Calculates difference between number of lines -3 and cursor position
#     DIFERENCE=$(($((LINES - 3)) - ${CURPOS%;*}))

#     # Prints debug on first line
#     #tput cup 0 0
#     #echo "LINES=$LINES CURPOS=$CURPOS DIFERENCE=$((${CURPOS%;*}-$((LINES-3))))"
#     #tput rc

#     # Do the magic (except it doesn't work)
#     if [[ $DIFERENCE -ge 0 ]]; then
#         echo -e "\033[1;$((LINES - 3))r"
#         tput rc
#     elif [[ $DIFERENCE -eq -1 ]]; then
#         tput cup $LINES 0
#         #for ((i=-1; i>=$DIFERENCE; i--)); do echo -en '\n'; done
#         echo -e "\n\033[1;$((LINES - 3))r"
#         tput rc
#         tput cuu1
#     fi
# }
# Runs _fix_bottom_padding each time the window is resized:
# trap '_fix_bottom_padding' WINCH

#Sets bottom padding and changes clear alias **only** in TTYs
#if [[ ! $DISPLAY ]]; then
#  _clear
#  _set_bottom_padding
#  alias clear="_clear; _set_bottom_padding"
#fi

# Lets disable the embedded prompt and make our own :)
export VIRTUAL_ENV_DISABLE_PROMPT=0
function _virtualenv_info() {
    [[ -n "$VIRTUAL_ENV" ]] && echo "${VIRTUAL_ENV##*/}"
}

# Helper function that truncates $PWD depending on window width
# Optionally specify maximum length as parameter (defaults to 1/3 of terminal)
function _get_truncated_pwd() {
    local tilde="~"
    local newPWD="${PWD/#${HOME}/${tilde}}"
    local pwdmaxlen="${1:-$((${COLUMNS:-80} / 3))}"
    [[ "${#newPWD}" -gt "${pwdmaxlen}" ]] && newPWD="…${newPWD:3-$pwdmaxlen}"
    echo -n "${newPWD}"
}

#####################################
## The Divine and Beautiful Prompt ##
#####################################
## Install 'fortune', 'cowthink' and 'lolcat' and have fun every time you open up a terminal.
[[ "$PS1" ]] && hash "fortune" "cowthink" "lolcat" >&/dev/null && fortune -s -n 200 | cowthink | lolcat -F 0.1 -p 30 -S 1

function _pre_command() {
    # Show the currently running command in the terminal title:
    # *see http://www.davidpashley.com/articles/xterm-titles-with-bash.html
    # *see https://gist.github.com/fly-away/751f32e7f6150419697d
    # *see https://goo.gl/xJMzHG

    # Instead of using $BASH_COMMAND, which doesn't deals with aliases,
    # uses an awesome tip by @zeroimpl. It's scary, touch it and it breaks!!!
    # *see https://goo.gl/2ZFDfM
    local this_command=$(HISTTIMEFORMAT= history 1 | \sed -e "s/^[ ]*[0-9]*[ ]*//")
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
    # Must come first, the girl.
    _last_command=$?

    # Saves on history after each command
    history -a
    # Not working crazy shit that's supposed to actually erase previous dups (https://goo.gl/DXAcPO)
    # history -n; history -w; history -c; history -r;

    # Colors
    Blue='\[\e[01;34m\]'
    Bluelly='\[\e[38;5;31;1m\]'
    White='\[\e[01;37m\]'
    Violet='\[\e[01;35m\]'
    Magenta='\[\e[01;36m\]'
    Red='\[\e[01;31m\]'
    Green='\[\e[01;32m\]'
    GreenLight='\[\e[01;92m\]'
    YellowLight='\[\e[01;93m\]'
    VioletLight='\[\e[01;95m\]'
    PinkLight='\[\e[00;91m\]'
    GrayBackground='\[\e[01;40m\]'
    # 1337 users get different colors
    # a.k.a: warns if you're in a root shell

    # TODO: fix this shit, do not set the color according to the user
    #       actually, set global colors to be used all along this file
    if [ $(id -u) -eq 0 ]; then
        YellowB='\[\e[01;31m\]'
        YellowN='\[\e[00;31m\]'
    else
        YellowB='\[\e[01;33m\]'
        YellowN='\[\e[00;33m\]'
    fi

    Reset='\[\e[00m\]'
    FancyX='\342\234\227'
    Checkmark='\342\234\223'

    ######################
    ## Teh Prompt (PS1) ##
    ######################
    # Prints  ---\n\n after previous command without spawning
    # a newline after it, so you can actually easily notice
    # if it's output has an EOF linebreak.
    PS1="$YellowN---$Reset\\n\\n"


    ## FIXME: fix this shit. maybe this? http://tinyurl.com/yfa8cwam
    ## Sends a notification if command took longer than 60 seconds and finished
    ## Good for when updating and when you forget you had something running.
    # if [[ -n $NOTIFY_SLOW_COMMANDS && -n $_cmd_starttime ]]; then
    #     _cmd_endtime=$(date +%s)
    #     _time_taken_seconds=$((_cmd_endtime - _cmd_starttime))
    #     if [[ $_time_taken_seconds -ge 60 ]]; then
    #         # If cmd took more than 60 seconds to finish, notify
    #         icon=dialog-information
    #         urgency=low
    #         if [[ $_last_command != 0 ]]; then
    #             # high priority for error codes > 0
    #             icon=dialog-error
    #             urgency=critical
    #         fi
    #         notify-send -i $icon -u $urgency "$(fc -ln -1) completed in $_time_taken_seconds"
    #     fi
    # fi


    if [[ $_last_command == 0 ]]; then
        # If last cmd didn't return an error (exit code == 0)
        PS1+="$Green$Checkmark ${White}000 "
        PS1+="$Green\\u@\\h"
    else
        PS1+="$Red$FancyX $White$(printf "%03d" $_last_command) "
        PS1+="$Red\\u@\\h"
    fi

    # Nicely shows you're in a python virtual environment
    if [[ -n $VIRTUAL_ENV ]]; then
        PS1+=" $Magenta(venv:$(_virtualenv_info))"
    fi

    ## Nicely shows you're in a git repository
    ## TODO: @see: /usr/share/git/git-prompt.sh for more use cases and much more robust
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

        # TODO: do not repeat yourself yourself
        #       use git status once, save its output and fix this crappy code
        if [[ $(git status 2>/dev/null | tail -n1) == *"nothing to commit"* ]]; then
            if [[ $branch_name == "$short_sha" ]]; then
                PS1+="${GrayBackground}${White}→ $branch_name$Reset" # DETACHED HEAD
            else
                PS1+="$GreenLight→ $branch_name•$Reset"
            fi
        elif [[ $(git status 2>/dev/null | head -n5) == *"Changes to be committed"* ]]; then
            PS1+="$Bluelly→ $branch_name+$Reset"
        elif git status --porcelain --untracked-files=normal 2>/dev/null | grep -q "^\?\?"; then
            PS1+="$Magenta• $branch_name?$Reset"
        else
            PS1+="$YellowB✔ $branch_name*$Reset"
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
    ## @see: https://superuser.com/questions/187455/right-align-part-of-prompt
    # Create a string like:  "[ Apr 25 16:06 ]" with time in RED.
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

    PS1="\[${Save}\e[${COLUMNS:-$(tput cols)}C\e[${#PS1RHS_stripped}D${PS1RHS}${Rest}\]${PS1}"

    # Changes the terminal window title to the current dir by default, truncating if too long.
    PS1="\033]0;$(_get_truncated_pwd)\007${PS1}"

    # Otherwise, if something is currently running, run _pre_command and change title to the app's name.
    _cmd_starttime="$(date +%s)"
    trap '_pre_command' DEBUG
}

## vte.sh
# Fixes a bug (http://tinyurl.com/ohy3kmb) where spawning a new tab or window in gnome-terminal
# does not keep the current PWD, and defaults back to HOME (http://tinyurl.com/y7yknu3r).
# vte.sh replaces your PROMPT_COMMAND, so just source it and add it's function '__vte_prompt_command'
# to the end of your own PROMPT_COMMAND.
if [[ ! -z $VTE_VERSION && -f /etc/profile.d/vte.sh ]]; then
    source /etc/profile.d/vte.sh
    PROMPT_COMMAND='_set_prompt;__vte_prompt_command'
else
    PROMPT_COMMAND='_set_prompt'
fi


## PERSONAL RANDOM STUFF YOU PROBABLY WONT NEED
if [[ $ENABLE_RANDOM_STUFF == "$USER" ]]; then
    # MagicCD
    alias cdb='_magicCD 2 $HOME/Bravi/'
    alias cdp='_magicCD 3 $HOME/Coding/'

    # Uses open-subl3 instead of plain subl3 (so it doesn't changes workspaces if there's an instance already opened)
    alias subl3='open-subl3'
    alias subl='open-subl3'

    # Uses perl-rename as default for rename
    alias rename='perl-rename'

    ## Dangerous stuff that interferes with scripts
    ## Put these at the end of your .bashrc preferably so it doesn't
    ## intereferes with anything that is being done there.
    # Allows non case-sensitive wildcard globs (*, ?):
    # shopt -s nocaseglob
    # Allows extended wildcard globs
    # shopt -s extglob
    # Enables the ** glob
    shopt -s globstar

    ####################
    ## In development ##
    ####################
    # Use exit status from declare command to determine whether input argument is a
    # bash function
    function is_function() {
        declare -Ff "${1}" >/dev/null
    }

    # Helper function to read the first line of a file into a variable.
    # __git_eread requires 2 arguments, the file path and the name of the
    # variable, in that order.
    function __git_eread() {
        echo 'USING GIT EREAD'
        test -r "$1" && IFS=$'\r\n' read "$2" <"$1"
    }

    # TODO: check what is this for
    # source /usr/share/nvm/init-nvm.sh
fi
