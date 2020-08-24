#
# ~/.bash_profile
#
# Author: Emiliano Sauvisky

# Os requisitos para funcionar são:
# - Este arquivo deve estar sincronizado (link simbólico) entre root e usuário
# - O serviço getty@tty1 deve pular o login e mudar para tty2
# - O serviço getty@tty2 deve fazer auto-login do usuário
# - O .xinitrc do usuário deve estar propriamente configurado e funcionando

#Inicia o X automaticamente após o login no tty1 somente se não for root
# if [[ ! $DISPLAY && $(tty) == /dev/tty1 && $EUID -gt 0 ]]; then
#     # Faz com que o X fique spawning back se fizer LogOut no Gnome
#     #exec startx

#     # Faz com que o usuário fique logado se fizer LogOut no Gnome
#     startx
# fi

if [[ -z $DISPLAY && $(tty) == /dev/tty2 ]]; then
    GDK_BACKEND=x11 startx
fi

# Carrega o .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc
