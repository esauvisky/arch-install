#!/bin/sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Mperge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

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

########## Autostart ##########
## Trazer tudo de .config/autostart para aqui!
## Para evitar programas de adicionar automaticamente autostarts em
## .config/autostart (como o dropbox), adicionar o atributo immutable no diretório,
## via o comando abaixo
##     sudo chattr +i /home/esauvisky/config/autostart

# Gnome-Tweak Ignore Lid Switch
echo "Running gnome-tweak-tool-lid-inhibitor"
/usr/lib/gnome-tweak-tool-lid-inhibitor &

# xscreensaver
xscreensaver & xscreensaver-stopper &

# Deluge
sleep 5 && ( 
    deluged && sleep 5 &&
    if [[ $(deluge-console info | egrep -c 'Error|Downloading') -eq 0 ]]; then
        killall deluged
    else
        killall deluged && systemd-run --user --unit deluge deluge
    fi) &

# Roda o TitanIV
echo "Running Discord's Bot: TitanIV"
systemd-run --user --unit TitanIV /home/esauvisky/Coding/Discord/TitanIV/titan_start.sh &

# Roda dropbox depois de 20 segundos
echo "Running dropbox..."
sleep 10 && systemd-run --user --unit Dropbox dropbox &

echo "Running electrum..."
sleep 10 && systemd-run --user --unit electrum electrum --dir ~/.config/electrum --wallet ~/Documents/Wallets/native_wallet gui -m &

exec gnome-session
