#
# ~/.bash_profile
#
# Author: Emiliano Sauvisky

# Os requisitos para funcionar são:
# - Este arquivo deve estar sincronizado (link simbólico) entre root e usuário
# - O serviço getty@tty1 deve pular o login e mudar para tty2 
# - O serviço getty@tty2 deve fazer auto-login do usuário
# - O .xinitrc do usuário deve estar propriamente configurado e funcionando

# Inicia o X automaticamente após o login no tty2 somente se não for root
if [[ ! $DISPLAY && $XDG_VTNR -eq 2 && $EUID -gt 0 ]]; then
    exec startx
fi

# Carrega o .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc
