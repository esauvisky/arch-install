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
# Linka o bash ao gnome-keyring-daemon
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

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
#xscreensaver & xscreensaver-stopper &

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

# Roda dropbox depois de 10 segundos
echo "Running dropbox..."
sleep 10 && dropbox &
#sleep 10 && systemd-run --user --unit DropboxDelayed dropbox &

# Magica para fazer Alt+Tabs serem exclusivos por display (de acordo com o mouse)
# Autor da solução: https://goo.gl/KJ345J
# Autor 2 da solução (bash): https://goo.gl/xyC1Bs
sleep 10 && gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval 'imports.ui.altTab.WindowSwitcherPopup.prototype._getWindowList = function() {
let workspace = this._settings.get_boolean("current-workspace-only") ? global.screen.get_active_workspace() : null;
let allWindows = global.display.get_tab_list(Meta.TabList.NORMAL, workspace);
allWindows = allWindows.filter(w => w.get_monitor() === global.screen.get_current_monitor());
return allWindows;
}' &

#echo "Running electrum..."
#sleep 10 && systemd-run --user --unit electrum electrum --dir ~/.config/electrum --wallet ~/Documents/Wallets/native_wallet gui -m &

exec gnome-session
