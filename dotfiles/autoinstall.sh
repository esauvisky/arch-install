#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors
# Uncomment line below for debugging:
#PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
__deps=("sed" "grep")
for dep in "${__deps[@]}"; do hash $dep >&/dev/null || (echo "$dep was not found. Please install it and try again." && exit 1); done

dotfiles=(".bashrc" ".bash_completion" ".dircolors" ".inputrc" ".toprc")

cd "$HOME"

if ! hash wget 2>/dev/null; then
    if hash pacman 2>/dev/null; then
        echo -n "I need wget to be installed for this to work. May I? "
        read -p " [Y/n] " -r
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Well sorry then. Get wget first."
        else
            pacman -S --needed --noconfirm wget
        fi
    elif hash apt 2>/dev/null; then
        echo -n "I need wget to be installed for this to work. May I? "
        read -p " [Y/n] " -r
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Well sorry then. Get wget first."
        else
            apt install wget
        fi
    fi
fi

if hash gio 2>/dev/null; then
    # has gio support, can send older scripts to trash
    for dep in "${dotfiles[@]}"; do
        echo "Downloading script $dep from esauvisky/arch-install/master/dotfiles"
        url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"
        wget -q "$url" -O "$dep.1" || curl -o "$dep.1" "$url"
        gio trash -f "./$dep"
        mv "./$dep.1" "./$dep"
        if [[ -f "./$dep" ]]; then
            echo -e "All good! Moving on...\n"
        fi
    done
    echo -e "Everything went well! Your old files are in the trashbin in case something explodes. Buh-bye!"
else
    # no gio support, better backup in place
    for dep in "${dotfiles[@]}"; do
        echo "Downloading script $dep from esauvisky/arch-install/master/dotfiles"
        url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"
        wget -q "$url" -O "$dep.1" || curl -o "$dep.1" "$url"
        mv "./$dep" "./$dep.bak" || true
        mv "./$dep.1" "./$dep"
        if [[ -f "./$dep" ]]; then
            echo -e "All good! Moving on...\n"
        fi
    done
    echo -e "Everything went well! Your old files are backed up with a .bak extension! Buh-bye!"
fi

if hash pacman 2>/dev/null; then
    echo -en "\n\nBtw, you use Arch. Might I install a couple cool shit for this to work even better?"
    read -p " [Y/n] " -r
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        pacman -S --needed --noconfirm grc cowsay fortune-mod lolcat ccze colordiff nano
    fi
elif hash apt 2>/dev/null; then
    echo -en "\n\nI see you're not an Arch user, but at least it's linux.\nMight I install a couple cool shit for this to work even better?"
    read -p " [Y/n] " -r
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        apt install grc cowsay fortune-mod lolcat ccze colordiff nano
    fi
fi

echo -e "\n That's all! KTHXBYE"
