#!/bin/sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Merge in defaults and keymaps
if [ -f $sysresources ]; then xrdb -merge $sysresources; fi
if [ -f $sysmodmap ]; then xmodmap $sysmodmap; fi
if [ -f "$userresources" ]; then xrdb -merge "$userresources"; fi
if [ -f "$usermodmap" ]; then xmodmap "$usermodmap"; fi

# Start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

#### Variáveis de ambiente ####
# Faz com que o diretório padrão do gimp seja .config/gimp-2.8 e não ~/.gimp-2.8
export GIMP2_DIRECTORY="/home/esauvisky/.config/gimp-2.8"

# Faz com que a Radeon seja a placa padrão pra tudo (esquenta pra caralho!)
#export DRI_PRIME=0

# Linka o bash ao gnome-keyring-daemon
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK


########## Autostart ##########
## Trazer tudo de .config/autostart para aqui!
## Para evitar programas de adicionar automaticamente autostarts em
## .config/autostart (como o dropbox), adicionar o atributo immutable no diretório.

## Além disso, é melhor criar unidades do systemd em .config/systemd/user e dar enable
## em vez de rodar como o exemplo abaixo, ou diretamente como o ignore-lid-switch abaixo.

## Criando e rodando uma unidade do systemd on-the-go
# echo "Running Discord's Bot: TitanIV"
# systemd-run --user --unit TitanIV

# Gnome-Tweak Ignore Lid Switch
/usr/lib/gnome-tweak-tool-lid-inhibitor &

# msgrs
slack &
telegram-desktop &
keybase-gui &

# Allows to lock the screen
gnome-screensaver &

# Deluge
sleep 5 && (
    deluged && sleep 5 &&
    if [[ $(deluge-console info | egrep -c 'Error|Downloading') -eq 0 ]]; then
        killall deluged
    else
        killall deluged && systemd-run --user --unit deluge deluge
    fi) &

#echo "Running electrum..."
#sleep 10 && systemd-run --user --unit electrum electrum --dir ~/.config/electrum --wallet ~/Documents/Wallets/native_wallet gui -m &

exec gnome-session
#exec twm

