# ~/.bashrc
#
# Author: Emiliano Sauvisky

# Se não estiver rodando interativamente, não fazer nada
[[ $- != *i* ]] && return

########################### CONTROLES DE HISTÓRICO ############################
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
# Ignora comandos repetidos
export HISTCONTROL=ignoredups
# Prefixo das entradas do histórico em formato data (strftime) para saber em que data o comando foi executado.
export HISTTIMEFORMAT='[%F %T] '

############################## SALVA LOGS STDOUT ##############################
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

############################ VARIÁVEIS DE AMBIENTE ############################
# Seta a variável EDITOR (subl3 para usuários, nano para root)
[[ $EUID -gt 0 ]] && export EDITOR="subl3" || export EDITOR="nano"
export LESS="-P ?c<- .?f%f:Standard input.  ?n:?eEND:?p%pj\%.. .?c%ccol . ?mFile %i of %m  .?xNext\ %x.%t   Press h for help"
export IGNOREEOF=1

################################### ALIASES ###################################
# permite utilizar aliases após o sudo (por causa do espaço)
alias sudo='sudo '
# ls com classificação listar e cores
alias ls='ls -Fl --color=always'
# grep com numeros de linha e cores
alias grep="grep -n -C 2 --color=always"
# mkdir recursivo
alias mkdir="mkdir -p"
# alias para tageador de músicas
alias et="emiliano-tag"
# entra na pasta de projetos de programação
alias cdp="cd /home/esauvisky/Documentos/Programacao/Projetos/"
# cd no desktop
alias cdd="cd /home/esauvisky/Downloads/Desktop/"
# alias para diff
alias diff="colordiff -b -U -1"
# alias para color em watch
alias watch='watch --color -n0.5'

# abre o journal
alias je='journalctl -ef | ccze'
alias jb='journalctl -b | ccze'

# hahaha
alias gedit='subl3open'

# alias dd
alias dd='dd status=progress oflag=sync'

# usar perl-rename ao inves de rename
alias rename='perl-rename'

### Aliases pacman
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
alias pacsyu="sudo pacman -Syu && aurget -Syu --noconfirm"
# alias pacsyu="echo -n 'Limite de kbps? [700] '; read kbps; if test ! \$kbps; then kbps=700; fi; sudo trickle -s -d \$kbps pacman  -Syu --noconfirm; trickle -s -d \$kbps aurget -Syu --deps --noconfirm"
# pesquisa, pelo aurget, cada pacote da AUR instalado localmente (para verificar pacotes outdated)
alias aurcheck="\pacman -Qm | sed 's/ .*$//' | while read line; do echo -e \"\e[01;37m\$line:\"; aurget -Ss \$line | grep aur\/\$line; read; done"
# comandos para otimização do pacman
#alias pacfix="sudo pacman-optimize; sudo pacman -Sc; sudo pacman -Syy; echo 'Verificando arquivos de pacotes faltantes no sistema...'; sudo pacman -Qk | grep -v 'Faltando 0'; sudo abs"

############################## FUNÇÕES DIVERSAS ###############################
# Descompactador de arquivos
function extract()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
else
    echo "'$1' is not a valid file"
fi
}

##### Wrappers autocomplete do bash (para autocompletar os aliases) ######
# Carregar bash_completion pro pacman
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
    . /usr/share/bash-completion/completions/pacman
fi
_pacman_sync () {   # autocomplete pacman -S
    COMPREPLY=()
    cur=`_get_cword`
    _pacman_pkg Slq
}
_pacman_remove () { # autocomplete pacman -R
    COMPREPLY=()
    cur=`_get_cword`
    _pacman_pkg Qq
}
complete -F _pacman_sync pacs
complete -F _pacman_remove pacr
complete -F _pacman_sync pacss
complete -F _pacman_sync paci
complete -F _pacman_sync pacl

########################### CONFIGURAÇÕES VARIADAS ############################
##  Cuidado! Estas configurações alteram o funcionamento padrão de scripts   ##
# Permite expansão case-insensitive de globs (*, ?).
#shopt -s nocaseglob
# Permite expansão avançada de globs (*, ?).
#shopt -s extglob
# Remove o keybind Ctrl+W e Ctrl+D do stty para poder setar em .inputrc
stty werase undef
stty eof undef

################################## PROMPT #####################################
# alias para limpar a tela de verdade (deve vir depois dos stty acima)
alias clear="echo -en '\033c'; echo -e '\033[1;'$((LINES-3))'r'"
echo -e '\033[1;'$((LINES-3))'r'
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
    PS1+="$Blue\\w\\n$YellowB\\\$ $YellowN"

    # Continuação (PS2)
    PS2=" | "

    # Debug (PS4)
    # FIXME: não funciona quando set -x é executando dentro do script. Inútil.
    # Provavelmente funciona legal se implementado diretamente no script a ser debugado com set -x.
    # Cuidado! O primeiro caractere da string (+) deve ser sem formatação,
    # pois o bash repete ele de acordo com a hierarquia dos subprocessos.
    PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'

    # Faz com que somente o comando fique em amarelo, e não o output do programa.
    trap 'echo -ne "\e[0m"' DEBUG
}

PROMPT_COMMAND='set_prompt'
