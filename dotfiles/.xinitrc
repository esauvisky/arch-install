#!/bin/bash
####################
# Xorg Boilerplate #
####################
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
## Merge in defaults and keymaps
if [ -f $sysresources ]; then xrdb -merge $sysresources; fi
if [ -f $sysmodmap ]; then xmodmap $sysmodmap; fi
if [ -f "$userresources" ]; then xrdb -merge "$userresources"; fi
if [ -f "$usermodmap" ]; then xmodmap "$usermodmap"; fi
## Start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

###########
# ENVVARS #
###########
## GPG Signing TTY
# Has to be called at the very beggining
GPG_TTY=$(tty)
export GPG_TTY

## Forces Radeon GPU for everything (don't. just don't do it unless you want your house in fire)
#export DRI_PRIME=0

## Default gimp config directory
export GIMP2_DIRECTORY="/home/esauvisky/.config/gimp-2.8"

## Links bash to gnome-keyring-daemon
eval "$(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)"
dbus-update-activation-environment --systemd DISPLAY
export "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)"

#############
# AUTOSTART #
#############
## Trazer tudo de .config/autostart para aqui!
## Para evitar programas de adicionar automaticamente autostarts em
## .config/autostart (como o dropbox), adicionar o atributo immutable no diretório.

## Além disso, é melhor criar unidades do systemd em .config/systemd/user e dar enable
## em vez de rodar como o exemplo abaixo, ou diretamente como o ignore-lid-switch abaixo.

## Criando e rodando uma unidade do systemd on-the-go
# echo "Running Discord's Bot: TitanIV"
# systemd-run --user --unit TitanIV

## Gnome-Tweak Ignore Lid Switch
# /usr/lib/gnome-tweak-tool-lid-inhibitor &

## Starts slack if it's job hours
if [[ $(date +%u) -lt 6 && $(date +%_H) -ge 8 && $(date +%_H) -le 18 ]]; then
    echo 'Starting slack application...'
    slack -u
fi

## Starts telegram
telegram-desktop &

# Allows to lock the screen
gnome-screensaver &

# Deluge
# sleep 5 && (
#     deluged && sleep 5 &&
#     if [[ $(deluge-console info | egrep -c 'Error|Downloading') -eq 0 ]]; then
#         killall deluged
#     else
#         killall deluged && systemd-run --user --unit deluge deluge
#     fi) &

#echo "Running electrum..."
#sleep 10 && systemd-run --user --unit electrum electrum --dir ~/.config/electrum --wallet ~/Documents/Wallets/native_wallet gui -m &

############
# SESSION #
###########
# GNOME on Xorg
export GDK_BACKEND=x11
# exec xrdb .Xresources & gnome-session
exec gnome-session

# # Gnome Classic
#export XDG_CURRENT_DESKTOP=GNOME-Classic:GNOME
#export GNOME_SHELL_SESSION_MODE=classic
#exec gnome-session --session=gnome-classic

#exec cinnamon-session
