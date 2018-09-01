# ~/.bashrc
#
# Author: Emiliano Sauvisky

# Se não estiver rodando interativamente, não fazer nada
[[ $- != *i* ]] && return

###################
# Command History #
###################
# Incrementa o histórico ao invés de reescrevê-lo sempre que a shell for fechada.
shopt -s histappend
# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Número máximo de entradas de histórico na sessão atual. (nada é infinito)
export HISTSIZE=50000
# Número máximo de linhas em HISTFILE. (nada é infinito)
export HISTFILESIZE=100000
# Ignora estes comandos e não os salva no histórico.
export HISTIGNORE="clear:exit:history"
# Ignora comandos duplicados ou já presentes no histórico, preservando a ordem
export HISTCONTROL=ignoreboth:erasedups
# Prefixo das entradas do histórico em formato data (strftime) para saber em que data o comando foi executado.
export HISTTIMEFORMAT='[%F %T] '

#####################
# STDOUT Log Saving #
#####################
# TODO: Needs some work
#if [ -z "$UNDER_SCRIPT" ]; then
#        logdir=$HOME/.terminal-logs
#        if [ ! -d $logdir ]; then mkdir $logdir; fi
#        if [[ $(du -sk $logdir | sed 's/\t.*$//') -gt 1000000 ]]; then
#            # removes oldest file ONCE
#            #echo "Removing oldest log"
#            rm $logdir/$(\ls -t $logdir | tail -1)
#        fi
#        #gzip -q $logdir/*.log
#        logfile=$logdir/$(date +%F_%T).$$.log
#        export UNDER_SCRIPT=$logfile
#        script -f -q $logfile
#        exit
#fi

#########################
# Environment Variables #
#########################
## You should really consider putting these in .xinitrc, depending on the intended behaviour
# Sets EDITOR env variable for user and root
[[ $EUID -gt 0 ]] && export EDITOR="subl3" || export EDITOR="nano"
# Magic with `less` (like colors and other cool stuff)
export LESS="R-P ?c<- .?f%f:Standard input.  ?n:?eEND:?p%pj\%.. .?c%ccol . ?mFile %i of %m  .?xNext\ %x.%t   Press h for help"
# Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1
## Cores!!!
# Originais:
#LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
# Baixadas:
[[ -f ~/.dircolors ]] && eval $(dircolors -b ~/.dircolors)

###########
# Aliases #
###########
## Configuração
# Permite utilizar outros alias após o sudo
# Quem faz a mágica é o espacinho no final.
alias sudo='sudo '

## Diretórios Prédefinidos
# Entra no diretório de Projetos
alias cdp="cd /home/esauvisky/Coding/Projects"


## Navegação
alias mkdir="mkdir -p"
alias go="xdg-open"
alias ls='ls -l --classify --human-readable --color=always --group-directories-first --literal --sort=extension --time-style=long-iso'


alias grep="grep -n -C 2 --color=always"
alias diff="colordiff -b -U -1"
alias watch='watch --color -n0.5'

## Logging
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

## Pacman Aliases
# obriga a utilizar o pacman
alias pacman="pacman"
# alias para instalar pacotes (não reinstala se já existir)
alias pacs="sudo pacman -S --needed"
# alias para remover pacotes (remove pacotes e dependências - se faltarem dependências adicionar -c)
alias pacr="sudo pacman -Rs"
# alias para pesquisar pacotes
alias pacss="pacman -Ss"
# alias para obter informações de pacotes
alias paci="pacman -Qi"
# alias para obter informações dos conteúdos de pacotes
alias pacl="pacman -Ql"
# atualiza o pacman e a AUR
alias pacsyu="log=\$HOME/.logs/\$(date +pacsyu@%F~%H:%S); sudo unbuffer -p pacman -Syu |& tee -a \$log; echo 'Press Enter to update AUR packages...'; read; unbuffer -p aurget -Syu |& tee -a \$log; echo 'Press Enter to update AUR devel (e.g.: -git) packages...'; read; unbuffer -p aurget -Syu --devel --noconfirm; echo 'Done! Log saved at $log.'; read"
# alias pacsyu="echo -n 'Limite de kbps? [700] '; read kbps; if test ! \$kbps; then kbps=700; fi; sudo trickle -s -d \$kbps pacman  -Syu --noconfirm; trickle -s -d \$kbps aurget -Syu --deps --noconfirm"
# pesquisa, pelo aurget, cada pacote da AUR instalado localmente (para verificar pacotes outdated)
alias aurcheck="\pacman -Qm | sed 's/ .*$//' | while read line; do echo -e \"\e[01;37m\$line:\"; aurget -Ss \$line | grep aur\/\$line; read; done"
# comandos para otimização do pacman
#alias pacfix="sudo pacman-optimize; sudo pacman -Sc; sudo pacman -Syy; echo 'Verificando arquivos de pacotes faltantes no sistema...'; sudo pacman -Qk | grep -v 'Faltando 0'; sudo abs"


## True screen clearing
function _clear () {
    echo -en "\033c"
}
alias clear="_clear"

# Load bash autocompletions
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

################################
# pacman Autocomplete Wrappers #
################################
# Loads pacman's completions
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/completions/pacman
fi
# Autocompletes `pacman -S`
function _pacman_sync () {
    COMPREPLY=()
    cur=`_get_cword`
    _pacman_pkg Slq
}
# Autocompletes `pacman -R`
function _pacman_remove () {
    COMPREPLY=()
    cur=`_get_cword`
    _pacman_pkg Qq
}
# Adds autocomplete functions to the alises as well
complete -F _pacman_sync pacs
complete -F _pacman_remove pacr
complete -F _pacman_sync pacss
complete -F _pacman_sync paci
complete -F _pacman_sync pacl

############################
# Bottom Padding (DECSTBM) #
############################
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
# Runs _fix_bottom_padding each time the window is resized
# trap '_fix_bottom_padding' WINCH

# Sets bottom padding and changes clear alias **only** in TTYs
if [[ ! $DISPLAY ]]; then
    _clear
    _set_bottom_padding
    alias clear="_clear; _set_bottom_padding"
fi


########################### CONFIGURAÇÕES VARIADAS ############################
##  TODO: Cuidado! Estas configurações alteram o funcionamento padrão de scripts   ##
# Permite expansão case-insensitive de globs (*, ?).
#shopt -s nocaseglob
# Permite expansão avançada de globs (*, ?).
#shopt -s extglob
# Remove o keybind Ctrl+W e Ctrl+D do stty para poder setar em .inputrc
stty werase undef
stty eof undef

##############
# The Prompt #
##############
[[ "$PS1" ]] && /usr/bin/fortune
set_prompt () {
    # Deve vir primeiro!
    Last_Command=$?

    # Salva o comando no histórico após cada comando
    history -a
    # crazy shit history -n; history -w; history -c; history -r;

    # Cores
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    Green='\[\e[01;32m\]'

    # Se o usuário é root, utilizar outras cores
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
        # Se o código de saída for diferente de 0 (erro)
        PS1+="$Green$Checkmark ${White}000 "
        PS1+="$Green\\u@\\h "
    else
        PS1+="$Red$FancyX $White"$(printf "%03d" $Last_Command)" "
        PS1+="$Red\\u@\\h "
    fi
    #PS1+="$Blue\\w\\n$YellowB\\\$ $YellowN"
    PS1+="$Blue\\w\\n$YellowB\\\$ $YellowN"

    # Continuação (PS2)
    PS2=" | "

    # Debug (PS4)
    # ** Não funciona quando set -x é executando fora do script! **
    # Funciona legal se implementado diretamente no script a ser debugado com set -x ou set -o xtrace.
    # Cuidado! O primeiro caractere da string (+) deve ser sem formatação, pois o bash repete ele de acordo com a hierarquia dos subprocessos.
    #PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'

    # Faz com que somente o comando fique em amarelo, e não o output do programa.
    trap 'echo -ne "\e[0m"' DEBUG
}

PROMPT_COMMAND='set_prompt'
