# ~/.bashrc
# Author: emi~ (@esauvisky)

###########
# CONFIGS #
###########
_ENABLE_RANDOM_STUFF=1       # Check the big if block at the end of the file
_CDZEIRO_DIR="$HOME/Coding/" # Check CDZEIRO function below

############################################
## THIS IS CERTAINLY NOT POSIX COMPATIBLE ##
############################################
## Don't do anything if not running interactively
[[ $- != *i* ]] && return

## GPG Signing TTY
# Has to be called at the very beggining
GPG_TTY=$(tty)]

#####################
# HISTORY SETTINGS #
####################
## Bash's eternal history
# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Maximum number of entries on the current session (nothing is infinite).
export HISTSIZE=500000
# Maximum number of lines in HISTFILE (nothing is infinite).
export HISTFILESIZE=1000000
# Commands to ignore and skip saving
export HISTIGNORE="clear:exit:history:cd .."
# Ignores dupes and deletes old ones (latest doesn't work _quite_ properly, but does the trick)
export HISTCONTROL=ignoredups:erasedups
# Custom history time prefix format
export HISTTIMEFORMAT='[%F %T] '
# ESSENTIAL: appends to the history at each command instead of writing everything when the shell exits.
shopt -s histappend

#########################
# Environment Variables #
#########################
## Magic with `less` (like colors and other cool stuff)
export LESS="R-P ?c<- .?f%f:Standard input.  ?n:?eEND:?p%pj\%.. .?c%ccol . ?mFile %i of %m  .?xNext\ %x.%t   Press h for help"

## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1

## Sets default EDITOR environment variable
if [[ ! -z $DISPLAY && ! $EUID -eq 0 ]]; then
    for editor in "subl3" "gedit"; do
        hash "$editor" >&/dev/null && export EDITOR=$editor && break || continue
        export EDITOR="vi"
    done
else
    # if root use exclusively non-gui editors
    hash "nano" >&/dev/null && export EDITOR="nano" || export EDITOR="vi"
fi

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

##################
# AUTOCOMPLETION #
##################
## Tip: Autocompletion for custom funcs without writing our own completion function
# 1. Type the command, and press <Tab> to autocomplete
# 2. Run `complete -p command`
# 3. The output is the hook that was used to complete it.
# 4. Change it accordingly to apply it to your function.

# Loads bash's system-wide installed completions
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
# Loads gits completion file for our custom completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

#####################
# STDOUT Log Saving #
#####################
if [ -z "$UNDER_SCRIPT" ]; then
    logdir=$HOME/.terminal-logs
    if [ ! -d $logdir ]; then mkdir $logdir; fi
    # Deletes all logs older than two weeks
    find ~/.terminal-logs/ -type f -name '*.log' -mtime +14 -exec rm {} \;
    # Compresses all logs older than one week
    find ~/.terminal-logs/ -type f -name '*.log' -mtime +7 -exec gzip -q {} \;
    logfile=$logdir/$(date +%F_%T).$$.log
    export UNDER_SCRIPT=$logfile
    script -f -q $logfile
    exit
fi

###########
# CDZEIRO #
###########
# Searches for directories up to two depth levels
# e.g.: `cdp Unik` would make it cd into ~/Coding/Android/MyUnikProject
#       if that's the only directory with 'Unik' in it's name.
function cdp() {
    # Black magic ;)
    # results=()
    # while IFS=  read -r -d $'\0'; do
    #     results+=("$REPLY")
    # done < <(find ${_CDZEIRO_DIR} -depth  -maxdepth 2 -type d -iname \*${*}\* -print0)

    # Neat black magic (bash 4.4 only)
    readarray -d '' results < <(find ${_CDZEIRO_DIR} -maxdepth 2 -type d -iname \*${*}\* -print0)

    # If there's an unique result for the argument, cd into it:
    if [[ ${#results[@]} -eq 1 ]]; then
        cd "${results[0]}"
    else
        cd "${_CDZEIRO_DIR}/Projects"
    fi
}

################
# COOL SPAWNER #
################
# Spawns a process and closes the terminal, without killing the process.
function e() {
    if [ -x "$(command -v ${1})" ] || alias ${1} &>/dev/null; then
        eval ${@} & disown
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
function findir() {
    find -type d -iname *${@}* 2>/dev/null
}

###########
# Aliases #
###########
## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '

## Navegação
alias clear='_clear'
alias mkdir="mkdir -p"
alias go="xdg-open"
alias ls=$_COLOURIFY_CMD" ls -oX --classify --human-readable -rt $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"

# Makes grep useful
alias grep="grep -n -C 2 $_COLOR_ALWAYS_ARG -E"
# Makes sed useful
alias sed="sed -E"
# Makes diff decent
alias diff="colordiff $_COLOR_ALWAYS_ARG -w -B -U 5 --suppress-common-lines"

## Logging
alias watch="watch --color -n0.5"
alias dmesg='dmesg --time-format ctime'
# Makes dd pretty
alias dd='dd status=progress oflag=sync'
# journalctl handy aliases
if hash "journalctl" >&/dev/null; then
    alias je=$_COLOURIFY_CMD' journalctl -ef'
    alias jb=$_COLOURIFY_CMD' journalctl -b'
fi

## Git
if hash "git" >&/dev/null; then
    alias gitl='git log --all --decorate=full --oneline'
    alias gits='git status'
    alias gitcam='git commit -a -m '
    function gitdelbranch() {
        # First command deletes local branch, but exits > 0 if not fully merged,
        # so the second command (which deletes the remote branch), will only run
        # if the first one suceeds, making it "safe".
        git branch --delete ${1} && git push origin --delete ${1}
    }
    # Autocomplete local branches only
    function_git_local_branches() {
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
    alias aurs="aurget --sort votes -Ss"
    alias pacman="pacman"
    alias pacs="sudo pacman -S --needed"
    alias pacr="sudo pacman -Rs"
    alias pacss="pacman -Ss"
    alias paci="pacman -Qi"
    alias pacl="pacman -Ql"
    complete -F _complete_alias aurs
    complete -F _complete_alias pacs
    complete -F _complete_alias pacr
    complete -F _complete_alias pacss
    complete -F _complete_alias paci
    complete -F _complete_alias pacl

    # Updater (pacman + aurget + aurget dev packages):
    alias pacsyu="log=\$HOME/.logs/\$(date +pacsyu@%F~%H:%S); sudo unbuffer -p pacman -Syu |& tee -a \$log; echo 'Press Enter to update AUR packages...'; read; unbuffer -p aurget -Syu |& tee -a \$log; echo 'Press Enter to update AUR devel (e.g.: -git) packages...'; read; unbuffer -p aurget -Syu --devel --noconfirm; echo 'Done! Log saved at $log.'; read"
    # pesquisa, pelo aurget, cada pacote da AUR instalado localmente (para verificar pacotes outdated)
    alias aurcheck="\pacman -Qm | \sed 's/ .*$//' | while read line; do echo -e \"\e[01;37m\$line:\"; aurget -Ss \$line | grep aur\/\$line; read; done"
    # comandos para otimização do pacman
    alias pacfix="sudo pacman-optimize; sudo pacman -Sc; sudo pacman -Syy; echo 'Verificando arquivos de pacotes faltantes no sistema...'; sudo pacman -Qk | grep -v 'Faltando 0'; sudo abs"
fi

############################
# Bottom Padding (DECSTBM) #
############################
## Besides the first couple functions, this attempt
## was a major fail. Any resizing of the window screws things up.
# True screen clearing
function _clear() {
    echo -en "\033c"
}

# # Leaves 3 lines of clearance at the bottom of the terminal
# function _set_bottom_padding() {
#     echo -e "\n\033[1;$((LINES - 3))r"
# }

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

# Sets bottom padding and changes clear alias **only** in TTYs
#if [[ ! $DISPLAY ]]; then
#   _clear
#   _set_bottom_padding
#   alias clear="_clear; _set_bottom_padding"
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
[[ "$PS1" ]] && hash "fortune" >&/dev/null && /usr/bin/fortune

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

# Helper function to read the first line of a file into a variable.
# __git_eread requires 2 arguments, the file path and the name of the
# variable, in that order.
function __git_eread() {
    test -r "$1" && IFS=$'\r\n' read "$2" <"$1"
}

function _set_prompt() {
    # Must come first
    Last_Command=$?

    # Saves on history after each command
    history -a
    # Crazy shit that's supposed to actually erase previous dups (https://goo.gl/DXAcPO)
    # doesn't work
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
    PinkLight='\[\e[01;91m\]'
    GrayBackground='\[\e[01;40m\]'


    # 1337 users get different colors
    # a.k.a: warns if you're in a root shell
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

    if [[ $Last_Command == 0 ]]; then
        # If last cmd didn't return an error (exit code == 0)
        PS1+="$Green$Checkmark ${White}000 "
        PS1+="$Green\\u@\\h"
    else
        PS1+="$Red$FancyX $White"$(printf "%03d" $Last_Command)" "
        PS1+="$Red\\u@\\h"
    fi

    # Nicely shows you're in a python virtual environment
    if [[ ! -z $VIRTUAL_ENV ]]; then
        PS1+=" $Magenta(venv:$(_virtualenv_info))"
    fi

    ## Nicely shows you're in a git repository
    ## @see: /usr/share/git/git-prompt.sh for more use cases and much more robust
    repo_info="$(git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --short HEAD 2>/dev/null)"
    rev_parse_exit_code="$?"

    if [[ ! -z $repo_info ]]; then
        if [ "$rev_parse_exit_code" = "0" ]; then
            short_sha="${repo_info##*$'\n'}"
            repo_info="${repo_info%$'\n'*}"
        fi
        branch_name=$(git symbolic-ref -q HEAD)
        branch_name=${branch_name##refs/heads/}
        branch_name=${branch_name:-$short_sha}

        PS1+=" $Violet["

        if [[ $(git status 2>/dev/null | tail -n1) == *"nothing to commit"* ]]; then
            [[ $branch_name == $short_sha ]] &&
                PS1+="${GrayBackground}${White}→ $branch_name$Reset" || # DETACHED HEAD
                PS1+="$GreenLight→ $branch_name•$Reset"                  # normal stuff
        elif [[ $(git status --porcelain --untracked-files=normal 2>/dev/null | grep "^\?\?") ]]; then
            PS1+="$YellowB→ $branch_name*$Reset"
        elif [[ $(git status 2>/dev/null | head -n5) == *"Changes to be committed"* ]]; then
            PS1+="$Blue→ $branch_name+$Reset"
        else
            PS1+="$YellowB→ $branch_name*$Reset"
        fi
        PS1+="$Violet]$Reset"
    fi

    Time12a="\$(date +%H:%M)"

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
    trap '_pre_command' DEBUG
}

## vte.sh
# Fixes a bug (http://tinyurl.com/ohy3kmb) where spawning a new tab or window in gnome-terminal
# does not keep the current PWD, and defaults back to HOME (http://tinyurl.com/y7yknu3r).
# vte.sh replaces your PROMPT_COMMAND, so just source it and add it's function '__vte_prompt_command'
# to the end of your own PROMPT_COMMAND.
if [[ ! -z $VTE_VERSION ]]; then
    source /etc/profile.d/vte.sh
    PROMPT_COMMAND='_set_prompt;__vte_prompt_command'
else
    PROMPT_COMMAND='_set_prompt'
fi


## transfer.sh
# TODO: refactor this, prettify and add auto copy to clipboard with xclip
transfer() { if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; }

## PERSONAL RANDOM STUFF YOU PROBABLY WONT NEED
if [[ $_ENABLE_RANDOM_STUFF ]]; then
    ## Diretórios Prédefinidos
    # Entra no diretório de Projetos
    alias cdb="cd $HOME/Bravi"
    alias cdbp="cd $HOME/Bravi/portal"
    alias cdbs="cd $HOME/Bravi/somos-ciee"
    alias cdbc="cd $HOME/Bravi/ciee-meta"
    alias cdpok="cd $HOME/Coding/Pokémon"

    ## Diretórios Prédefinidos
    # Entra no diretório de Projetos
    alias cdb="cd $HOME/Bravi"
    alias cdbp="cd $HOME/Bravi/portal"
    alias cdbs="cd $HOME/Bravi/somos-ciee"
    alias cdbc="cd $HOME/Bravi/ciee-meta"

    # Alias para usar open-subl3 no lugar de subl3
    alias subl3='open-subl3'
    alias subl='open-subl3'

    # Uses perl-rename as default for rename
    alias rename='perl-rename'

    # TODO: check what is this for
    source /usr/share/nvm/init-nvm.sh

    ## Dangerous stuff that interferes with scripts
    ## Put these at the end of your .bashrc preferably so it doesn't
    ## intereferes with anything that is being done there.
    # Allows non case-sensitive wildcard globs (*, ?):
    # shopt -s nocaseglob
    # Allows extended wildcard globs
    # shopt -s extglob
    # Enables the ** glob
    shopt -s globstar

    # In development:
    # add these from above (and whatever else necessary) to this one and ditch it
    # Use exit status from declare command to determine whether input argument is a
    # bash function
    function is_function() {
        declare -Ff "${1}" >/dev/null
    }
fi
