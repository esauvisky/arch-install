#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors
# Uncomment line below for debugging:
#PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
__deps=("sed" "grep")
for dep in "${__deps[@]}"; do hash $dep >&/dev/null || (echo "$dep was not found. Please install it and try again." && exit 1); done

if [[ ! -t 0 ]]; then
    echo -e '\n\nPlease run like this instead:\nbash -c "$(curl -sSL https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/autoinstall.sh)"' && exit 1
fi

dotfiles=(".bashrc" ".bash_completion" ".dircolors" ".inputrc" ".toprc" ".dircolors")
grcconfs=("conf.ant" "conf.blkid" "conf.common" "conf.configure" "conf.curl" "conf.cvs" "conf.df" "conf.diff" "conf.dig" "conf.dnf" "conf.dockerimages" "conf.dockerinfo" "conf.docker-machinels" "conf.dockernetwork" "conf.dockerps" "conf.dockerpull" "conf.dockersearch" "conf.dockerversion" "conf.du" "conf.dummy" "conf.efibootmgr" "conf.env" "conf.esperanto" "conf.fdisk" "conf.findmnt" "conf.free" "conf.gcc" "conf.getfacl" "conf.getsebool" "conf.go-test" "conf.id" "conf.ifconfig" "conf.iostat_sar" "conf.ip" "conf.ipaddr" "conf.ipneighbor" "conf.iproute" "conf.iptables" "conf.irclog" "conf.iwconfig" "conf.jobs" "conf.kubectl" "conf.last" "conf.ldap" "conf.log" "conf.ls" "conf.lsattr" "conf.lsblk" "conf.lsmod" "conf.lsof" "conf.lspci" "conf.mount" "conf.mtr" "conf.mvn" "conf.netstat" "conf.nmap" "conf.ntpdate" "conf.php" "conf.ping" "conf.ping2" "conf.proftpd" "conf.ps" "conf.pv" "conf.semanageboolean" "conf.semanagefcontext" "conf.semanageuser" "conf.sensors" "conf.showmount" "conf.sockstat" "conf.sql" "conf.ss" "conf.stat" "conf.sysctl" "conf.systemctl" "conf.tcpdump" "conf.traceroute" "conf.tune2fs" "conf.ulimit" "conf.uptime" "conf.vmstat" "conf.wdiff" "conf.whois" "conf.yaml" "grc.conf")

cd "$HOME"

echo "Downloading scripts from esauvisky/arch-install/master/dotfiles"
for dep in "${dotfiles[@]}"; do
    url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"

    if hash wget 2>/dev/null; then
        wget -q "$url" -O "$dep.1" 2>/dev/null
    else
        curl -H "cache-control: max-age=0" -o "$dep.1" "$url" 2>/dev/null
    fi

    if hash gio 2>/dev/null; then
        gio trash -f "./$dep"
    else
        mv "./$dep" "./$dep.bak" 2>/dev/null || true
    fi

    mv "./$dep.1" "./$dep"
done

echo "Downloading GRC config files from esauvisky/arch-install/master/dotfiles/grc"
for conf in "${grcconfs[@]}"; do
    url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/grc/$conf"
    mkdir -p .grc

    if hash wget 2>/dev/null; then
        wget -q "$url" -O ".grc/$conf.1" 2>/dev/null
    else
        curl -H "cache-control: max-age=0" -o ".grc/$conf.1" "$url" 2>/dev/null
    fi

    if hash gio 2>/dev/null; then
        gio trash -f ".grc/$dep"
    else
        mv "./$dep" "./$dep.bak" 2>/dev/null || true
    fi

    mv ".grc/$conf.1" ".grc/$conf"
done

if hash gio 2>/dev/null; then
    echo -e "Everything went well! Previous files are in the trash bin."
else
    echo -e "Everything went well! Previous files (if any) were backed up with a .bak extension!"
fi

if hash pacman 2>/dev/null; then
    echo -en "\n\nBtw, you use Arch. Might I install a couple cool shit for this to work even better?"
    read -p " [Y/n] "
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo pacman -S --needed --noconfirm grc cowsay fortune-mod lolcat ccze colordiff nano inetutils
    fi
elif hash apt 2>/dev/null; then
    echo -en "\n\nI see you're not an Arch user, but at least it's linux.\nMight I install a couple cool shit for this to work even better?"
    read -p " [Y/n] "
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo apt install grc cowsay fortune-mod lolcat ccze colordiff nano
    fi
fi

echo -e "\n That's all! KTHXBYE"
rm -f "$HOME/.emishrc_last_check" 2>/dev/null || true
bash --rcfile $HOME/.bashrc
