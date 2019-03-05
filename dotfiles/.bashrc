# ~/.bashrc
#
# Author: Emiliano Sauvisky

# Se não estiver rodando interativamente, não fazer nada
[[ $- != *i* ]] && return


########################
# Configs and Settings #
########################
## Bash's eternal history
# Incrementa o histórico ao invés de reescrevê-lo sempre que a shell for fechada.
shopt -s histappend
# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Número máximo de entradas de histórico na sessão atual. (nada é infinito)
export HISTSIZE=50000
# Número máximo de linhas em HISTFILE. (nada é infinito)
export HISTFILESIZE=100000
# Ignora estes comandos e não os salva no histórico.
export HISTIGNORE="clear:exit:history:cd .."
# Ignora comandos duplicados ou já presentes no histórico, preservando a ordem
export HISTCONTROL=ignoreboth:erasedups
# Prefixo das entradas do histórico em formato data (strftime) para saber em que data o comando foi executado.
export HISTTIMEFORMAT='[%F %T] '

## Keybind removal for my precious Control+W and Control+D (it's set up on .inputrc)
stty werase undef
stty eof undef

## Dangerous stuff that interferes with scripts.
# Permite expansão case-insensitive de globs (*, ?).
# shopt -s nocaseglob
# Permite expansão avançada de globs (*, ?).
# shopt -s extglob


#########################
# Environment Variables #
#########################
## Sets EDITOR env variable for user and root
[[ $EUID -gt 0 ]] && export EDITOR="subl3" || export EDITOR="nano"

## Magic with `less` (like colors and other cool stuff)
export LESS="R-P ?c<- .?f%f:Standard input.  ?n:?eEND:?p%pj\%.. .?c%ccol . ?mFile %i of %m  .?xNext\ %x.%t   Press h for help"

## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1


###################
## COLORS, LOTS! ##
###################
# Default Set:
# LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# Custom Sets:
[[ -f ~/.dircolors ]] && eval $(dircolors -b ~/.dircolors)   # LS_COLORS
source /etc/profile.d/grc.bashrc                             # grc


# Loads bash and pacman completions
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi


#####################
# STDOUT Log Saving #
#####################
if [ -z "$UNDER_SCRIPT" ]; then
    logdir=$HOME/.terminal-logs
    if [ ! -d $logdir ]; then mkdir $logdir; fi
    # TODO: This routine is very resource intensive
    # and slows down the shell init *considerably*.
    # if [[ $(du -sk $logdir | sed 's/\t.*$//') -gt 1000000 ]]; then
    #     # removes oldest file ONCE
    #     #echo "Removing oldest log"
    #     rm $logdir/$(\ls -t $logdir | tail -1)
    # fi
    # gzip -q $logdir/*.log
    logfile=$logdir/$(date +%F_%T).$$.log
    export UNDER_SCRIPT=$logfile
    script -f -q $logfile
    exit
fi


###########
# CDZEIRO #
###########
function cdzeiro() {
    cd /home/esauvisky/Coding/Projects
    search=$(fd -d1 -td -i -a ${*})

    if [[ $(fd -d1 -td -i -a ${*} | wc -l) -eq 1 ]]; then
        cd "${search}"
    fi
}


#########
# Alias #
#########
## Boilerplate
# Permite utilizar outros alias após o sudo
# Quem faz a mágica é o espacinho no final.
alias sudo='sudo '

## Diretórios Prédefinidos
# Entra no diretório de Projetos
alias cdp="cdzeiro"
alias cdb='cd /home/esauvisky/Bravi'
alias cdbp='cd /home/esauvisky/Bravi/portal'
alias cdbs='cd /home/esauvisky/Bravi/somos-ciee'
alias cdpok='cd /home/esauvisky/Coding/Pokémon'

## Navegação
alias clear='_clear'
alias mkdir="mkdir -p"
alias go="xdg-open"
alias ls='colourify ls -oX --classify --human-readable -rt --color=always --group-directories-first --literal --time-style=long-iso'

# Filtros e comparações
alias grep="grep -n -C 2 --color"
alias diff="colordiff -w -B -U 5 --suppress-common-lines"

## Logging
alias watch='watch --color -n0.5'
alias dmesg='dmesg --time-format ctime'
alias je='journalctl -ef'
alias jb='journalctl -b'

## Random
# Alias para usar open-subl3 no lugar de subl3
alias subl3='open-subl3'
alias subl='open-subl3'
# Adiciona flags no dd para verbosidade no progresso e auto-sync
alias dd='dd status=progress oflag=sync'
# Usa perl-rename quando chamando rename
alias rename='perl-rename'

## Git
alias gitl='git log --all --decorate=full --oneline'
alias gits='git status'
alias gitcam='git commit -a -m '
alias gitundo='git checkout -- '
alias gitr='git reset HEAD '


# Loads bash_completion.
# Dotfile .bash_completion does the magic afterwards.
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi


## Systemctl
alias start="systemctl start"
alias stop="systemctl stop"
alias restart="systemctl restart"
alias st="systemctl status -n9999 --no-legend -a -l"
complete -F _complete_alias start
complete -F _complete_alias stop
complete -F _complete_alias restart
complete -F _complete_alias st


## Pacman
alias pacman="pacman"
alias pacs="sudo pacman -S --needed"
alias pacr="sudo pacman -Rs"
alias pacss="pacman -Ss"
alias paci="pacman -Qi"
alias pacl="pacman -Ql"
complete -F _complete_alias pacs
complete -F _complete_alias pacr
complete -F _complete_alias pacss
complete -F _complete_alias paci
complete -F _complete_alias pacl


# Updaters
alias pacsyu="log=\$HOME/.logs/\$(date +pacsyu@%F~%H:%S); sudo unbuffer -p pacman -Syu |& tee -a \$log; echo 'Press Enter to update AUR packages...'; read; unbuffer -p aurget -Syu |& tee -a \$log; echo 'Press Enter to update AUR devel (e.g.: -git) packages...'; read; unbuffer -p aurget -Syu --devel --noconfirm; echo 'Done! Log saved at $log.'; read"
# alias pacsyu="echo -n 'Limite de kbps? [700] '; read kbps; if test ! \$kbps; then kbps=700; fi; sudo trickle -s -d \$kbps pacman  -Syu --noconfirm; trickle -s -d \$kbps aurget -Syu --deps --noconfirm"
# pesquisa, pelo aurget, cada pacote da AUR instalado localmente (para verificar pacotes outdated)
alias aurcheck="\pacman -Qm | sed 's/ .*$//' | while read line; do echo -e \"\e[01;37m\$line:\"; aurget -Ss \$line | grep aur\/\$line; read; done"
# comandos para otimização do pacman
#alias pacfix="sudo pacman-optimize; sudo pacman -Sc; sudo pacman -Syy; echo 'Verificando arquivos de pacotes faltantes no sistema...'; sudo pacman -Qk | grep -v 'Faltando 0'; sudo abs"




############################
# Bottom Padding (DECSTBM) #
############################
## Besides the first couple functions, this attempt
## was a major fail. Any resizing of the window screws things up.
# True screen clearing
function _clear () {
    echo -en "\033c"
}

# Leaves 3 lines of clearance at the bottom of the terminal
function _set_bottom_padding () {
    echo -e "\n\033[1;$((LINES-3))r"
}

# FIXME: Tries to fix the padding when resizing the terminal window
function _fix_bottom_padding () {
    # Saves current cursor position
    tput sc

    # Gets current cursor position
    echo -en "\E[6n"
    read -sdR CURPOS
    CURPOS=${CURPOS#*;}

    # Calculates difference between number of lines -3 and cursor position
    DIFERENCE=$(( $((LINES-3)) - ${CURPOS%;*} ))

    # Prints debug on first line
    #tput cup 0 0
    #echo "LINES=$LINES CURPOS=$CURPOS DIFERENCE=$((${CURPOS%;*}-$((LINES-3))))"
    #tput rc

    # Do the magic (except it doesn't work)
    if [[ $DIFERENCE -ge 0 ]]; then
        echo -e "\033[1;$((LINES-3))r"
        tput rc
    elif [[ $DIFERENCE -eq -1 ]]; then
        tput cup $LINES 0
        #for ((i=-1; i>=$DIFERENCE; i--)); do echo -en '\n'; done
        echo -e "\n\033[1;$((LINES-3))r"
        tput rc
        tput cuu1
    fi
}
# Runs _fix_bottom_padding each time the window is resized:
# trap '_fix_bottom_padding' WINCH

# Sets bottom padding and changes clear alias **only** in TTYs
if [[ ! $DISPLAY ]]; then
   _clear
   _set_bottom_padding
   alias clear="_clear; _set_bottom_padding"
fi


# Lets disable the embedded prompt and make our own :)
export VIRTUAL_ENV_DISABLE_PROMPT=0
function virtualenv_info {
    [[ -n "$VIRTUAL_ENV" ]] && echo "${VIRTUAL_ENV##*/}"
}


#####################################
## The Divine and Beautiful Prompt ##
#####################################
[[ "$PS1" ]] && /usr/bin/fortune

function set_title {
    # Changes the terminal title to the command that is going to be run
    echo -ne "\033]0;$BASH_COMMAND\007" > /dev/stderr

    # Small fix that clears up all prompt colors, so we don't colorize any output
    echo -ne "\e[0m"
}

set_prompt () {
    # Must come first
    Last_Command=$?

    # Saves on history after each command
    history -a
    # crazy shit history -n; history -w; history -c; history -r;

    # Colors
    Blue='\[\e[01;34m\]'
    Bluelly='\[\e[38;5;31;1m\]'
    White='\[\e[01;37m\]'
    Magenta='\[\e[01;36m\]'
    Red='\[\e[01;31m\]'
    Green='\[\e[01;32m\]'

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

    # Prompt (PS1)
    PS1="$YellowN---$Reset\\n\\n"
    if [[ $Last_Command == 0 ]]; then
        # If we didn't had an error (exit code == 0)
        PS1+="$Green$Checkmark ${White}000 "
        PS1+="$Green\\u@\\h"
    else
        PS1+="$Red$FancyX $White"$(printf "%03d" $Last_Command)" "
        PS1+="$Red\\u@\\h"
    fi

    # Deals with python venvs
    if [[ ! -z $VIRTUAL_ENV ]]; then
        PS1+=" $Magenta(venv:$(virtualenv_info))"
    fi

    PS1+=" $Bluelly\\w\\n$YellowB\\\$ $YellowN"

    # Aligns stuff when you don't close quotes
    PS2=" | "

    # Debug (PS4)
    # ** Does not work if set -x is used outside an script :( **
    # It works wonderfully if you copy this to the script and apply set -x there though.
    #PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'


    # Changes the terminal window title to the current dir by default.
    PS1="\033]0;\w\007${PS1}"

    # If something is running, run set_title and change to the program name.
    trap 'set_title' DEBUG
}

PROMPT_COMMAND='set_prompt'
