#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors
# Uncomment line below for debugging:
#PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
__deps=("sed" "grep")
for dep in "${__deps[@]}"; do hash "$dep" >&/dev/null || (echo "$dep was not found. Please install it and try again." && exit 1); done

QUIET=false
if [[ $1 == "--quiet" ]]; then
    QUIET=true
fi

dotfiles=(".bashrc" ".bash_completion" ".dircolors" ".inputrc" ".toprc" ".nanorc")
grcconfs=(conf.efibootmgr conf.free conf.log grc.conf)

# progress bar
_cols=$(($(tput cols) - 22))
progress() {
    local _progress _done _left _fill _empty _percentage
    _done=$1
    _total=$(($2-1))
    _percentage=$(((_done * 100 / _total * 100) / 100))
    _progress=$(((_done * _cols / _total * _cols) / _cols))
    _left=$((_cols - _progress))
    _fill=$(printf "%${_progress}s")
    _empty=$(printf "%${_left}s")
    printf "\rDownloading... \e[37;01m[${_fill// /#}${_empty// /-}] ${_percentage}%%"
}

cd "$HOME"
_count=0
[[ $QUIET == "true" ]] || echo -e "\e[34;01m\rDownloading scripts from esauvisky/arch-install/master/dotfiles\e[00m"
for dep in "${dotfiles[@]}"; do
    [[ $QUIET == "true" ]] || progress $((_count++)) "${#dotfiles[@]}"
    url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"

    if hash wget 2>/dev/null; then
        wget -q "$url" -O "$dep.1" 2>/dev/null
    else
        curl -H "cache-control: max-age=0" -o "$dep.1" "$url" 2>/dev/null
    fi

    if hash gio 2>/dev/null; then
        gio trash -f "./$dep" 2>/dev/null || true
    else
        mv "./$dep" "./$dep.bak" 2>/dev/null || true
    fi

    mv "./$dep.1" "./$dep" 2>/dev/null || true
done

_count=0
[[ $QUIET == "true" ]] || echo -en "\n\e[34;01mDownloading GRC config files from esauvisky/arch-install/master/dotfiles/.grc\n\e[00m"
for conf in "${grcconfs[@]}"; do
    [[ $QUIET == "true" ]] || progress $((_count++)) "${#grcconfs[@]}"
    url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/.grc/$conf"
    mkdir -p .grc 2>/dev/null || true

    if hash wget 2>/dev/null; then
        wget -q "$url" -O ".grc/$conf.1" 2>/dev/null
    else
        curl -H "cache-control: max-age=0" -o ".grc/$conf.1" "$url" 2>/dev/null
    fi

    if hash gio 2>/dev/null; then
        gio trash -f ".grc/$conf" 2>/dev/null || true
    else
        mv ".grc/$conf" ".grc/$conf.bak" 2>/dev/null || true
    fi

    mv ".grc/$conf.1" ".grc/$conf" || true
done

echo -e '\e[0m'
if [[ $SHELL != "/bin/bash" && $SHELL != "/usr/bin/bash" ]]; then
    # change default shell to bash
    if ! chsh -s /bin/bash; then
        echo -e "\e[31;01mFailed to change default shell to bash. Please do it manually.\e[00m"
    else
        echo -e "\e[31;01mYOUR SHELL WAS CHANGED TO BASH. PLEASE LOG OUT AND LOG IN AGAIN FOR IT TO WORK!\e[00m"
    fi
fi

if [[ $QUIET == "false" ]]; then
    if hash gio 2>/dev/null; then
        echo -e "Everything went well! Previous files are in the trash bin."
    else
        echo -e "Everything went well! Previous files (if any) were backed up with a .bak extension!"
    fi

    if hash pacman 2>/dev/null; then
        echo -en "\n\nBtw, you use Arch. Do you want to install a couple cool shit for this to work even better? [Y/n]"
        read -r answer < /dev/tty
        if [[ $answer == "Y" || $answer == "y" ]]; then
            if [[ $(id -u) -eq 0 ]]; then
                pacman -S --needed --noconfirm grc cowsay fortune-mod lolcat ccze colordiff nano inetutils nano-syntax-highlighting
            elif hash sudo 2>/dev/null; then
                sudo pacman -S --needed --noconfirm grc cowsay fortune-mod lolcat ccze colordiff nano inetutils nano-syntax-highlighting
            else
                echo -e "You need sudo to install this. Install it and try again."
            fi
        fi
    elif hash apt 2>/dev/null; then
        echo -en "\n\nI see you're not an Arch user, but at least it's linux. Do you want to install some software for this to work better? [Y/n]"
        read -r answer < /dev/tty
        if [[ $answer == "Y" || $answer == "y" ]]; then
            if [[ $(id -u) -eq 0 ]]; then
                apt install grc cowsay fortune-mod lolcat ccze colordiff nano
            elif hash sudo 2>/dev/null; then
                sudo apt install grc cowsay fortune-mod lolcat ccze colordiff nano
            else
                echo -e "You need sudo to install this. Install it and try again."
            fi
        fi
    fi

    if hash nano 2>/dev/null; then
        echo -e "Adding syntax highlighting to nano..."
        find /usr/share/nano* -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc
    fi

    if ! ([[ $(id -u) -eq 0 ]] || hash sudo 2>/dev/null); then
        echo -e "You need to be root or have sudo to be able to get additional options. Run this script again with sudo or as root."
        exit 0
    fi

    echo -e "\nDo you want to copy your .nanorc to the global /etc/nanorc and uncomment root colors? [Y/n]"
    read -r answer < /dev/tty
    if [[ $answer == "Y" || $answer == "y" ]]; then
        sudo cp ~/.nanorc /etc/nanorc
        sudo sed -i '/^## Colors for user/,/^####/d' /etc/nanorc
        sudo sed -i 's/^###//' /etc/nanorc
    fi

    echo -e "\nDo you want new users on this machine to automatically have emi's bashrc installed by default? [Y/n]"
    read -r answer < /dev/tty
    if [[ $answer == "Y" || $answer == "y" ]]; then
        sudo cp -r ~/.bashrc ~/.bash_completion ~/.dircolors ~/.inputrc ~/.toprc ~/.nanorc ~/.grc /etc/skel/
    fi

    echo -e "\nDo you want to link all users' bash history to root's bash history, effectively sharing the history between all users? [y/N]"
    read -r answer < /dev/tty
    if [[ $answer == "Y" || $answer == "y" ]]; then
        sudo touch /root/.bash_eternal_history
        sudo ln -sf /root/.bash_eternal_history /etc/skel/.bash_eternal_history
        for user_home in /home/*; do
            sudo ln -sf /root/.bash_eternal_history "$user_home/.bash_eternal_history"
        done
    fi

    echo -e "That's all! KTHXBYE\n\n"
fi
rm -f "$HOME/.emishrc_last_check" 2>/dev/null || true
