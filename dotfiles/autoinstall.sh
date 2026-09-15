#!/usr/bin/env bash
# shellcheck disable=SC2015
#
#   emishrc installer / updater
#   curl -sL https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/autoinstall.sh | bash
#
#   What it touches:
#     ~/.emishrc/       replaced wholesale, every run
#     ~/.inputrc etc.   replaced, every run (previous copy trashed or .bak'd)
#     ~/.bashrc         written ONLY if it has no emishrc block yet; after that
#                       it is yours forever and updates never look at it again
#
set -o errtrace

QUIET=false
[[ ${1:-} == "--quiet" ]] && QUIET=true

RAW="${EMISHRC_RAW:-https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles}"
BLOCK_START="# >>> emishrc >>>"
BLOCK_END="# <<< emishrc <<<"
MIGRATION_MARK="# --- migrated from ~/.bash_custom by emishrc ---"

for dep in sed grep mktemp; do
    command -v "$dep" >/dev/null 2>&1 || { echo "$dep was not found. Please install it and try again." >&2; exit 1; }
done
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || {
    echo "Neither curl nor wget was found. Please install one and try again." >&2; exit 1; }

say()  { [[ $QUIET == true ]] || echo -e "$*"; }
die()  { echo -e "\e[31;01m$*\e[00m" >&2; exit 1; }

fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -H "cache-control: no-cache" "$1"
    else
        wget -q -O - "$1"
    fi
}

## Trash a file if we can, otherwise keep a .bak next to it.
retire() {
    [[ -e $1 || -L $1 ]] || return 0
    if command -v gio >/dev/null 2>&1; then
        gio trash -f "$1" 2>/dev/null && return 0
    fi
    mv -f "$1" "$1.bak" 2>/dev/null || rm -rf "$1"
}

#  +-+-+-+-+-+-+-+-+-+
#  |D|o|w|n|l|o|a|d|s|
#  +-+-+-+-+-+-+-+-+-+
# Everything lands in a staging dir inside $HOME first (same filesystem, so the
# final move is cheap) and nothing is installed unless every file arrived.

STAGE=$(mktemp -d "$HOME/.emishrc.staging.XXXXXX") || die "Could not create a staging directory in $HOME."
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT INT TERM HUP

say "\e[34;01mFetching emishrc from esauvisky/arch-install\e[00m"

manifest=$(fetch "$RAW/.emishrc/MANIFEST") || die "Could not download the file manifest. Aborting, nothing was changed."
grep -q '^\.emishrc/init\.sh$' <<<"$manifest" || die "The downloaded manifest looks wrong. Aborting, nothing was changed."

total=$(grep -c . <<<"$manifest")
count=0
_cols=$(( $(tput cols 2>/dev/null || echo 80) - 22 ))
[[ $_cols -lt 10 ]] && _cols=10

progress() {
    local done=$1 total=$2 filled empty pct
    [[ $total -le 0 ]] && return
    pct=$((done * 100 / total))
    filled=$((done * _cols / total))
    empty=$((_cols - filled))
    printf "\rDownloading... \e[37;01m[%s%s] %3d%%\e[00m" \
        "$(printf "%${filled}s" | tr ' ' '#')" "$(printf "%${empty}s" | tr ' ' '-')" "$pct"
}

while IFS= read -r path; do
    [[ -n $path ]] || continue
    count=$((count + 1))
    [[ $QUIET == true ]] || progress "$count" "$total"
    mkdir -p "$STAGE/$(dirname "$path")"
    fetch "$RAW/$path" > "$STAGE/$path" || die "\nFailed to download $path. Aborting, nothing was changed."
    [[ -s "$STAGE/$path" ]] || die "\n$path came back empty. Aborting, nothing was changed."
done <<<"$manifest"
say ""

## ~/.bashrc is not in the manifest (it is installed once, never updated) but we
## need the template on hand before touching anything.
fetch "$RAW/.bashrc" | grep -v 'legacy update marker' > "$STAGE/bashrc-template" ||
    die "Could not download the .bashrc template. Aborting, nothing was changed."
[[ -s "$STAGE/bashrc-template" ]] || die "The .bashrc template came back empty. Aborting, nothing was changed."

## Refuse to install shell code that does not even parse.
for script in "$STAGE"/.emishrc/*.sh "$STAGE"/.emishrc/rc.d/*.sh; do
    [[ -f $script ]] || continue
    bash -n "$script" 2>/dev/null || die "$script failed to parse. Aborting, nothing was changed."
done

#  +-+-+-+-+-+-+-+-+-+
#  |I|n|s|t|a|l|l|i|n|g|
#  +-+-+-+-+-+-+-+-+-+

## ~/.emishrc/ is fully managed: swap the whole directory. Updates run daily, so
## keep exactly one previous copy around instead of filling the trash with them.
rm -rf "$HOME/.emishrc.bak"
[[ -e "$HOME/.emishrc" ]] && mv -f "$HOME/.emishrc" "$HOME/.emishrc.bak"
mv "$STAGE/.emishrc" "$HOME/.emishrc" || die "Could not install $HOME/.emishrc."
chmod +x "$HOME/.emishrc"/*.sh "$HOME/.emishrc"/rc.d/*.sh 2>/dev/null

## The standalone dotfiles keep the old behaviour: replaced on every update.
while IFS= read -r path; do
    [[ -n $path && $path != .emishrc/* ]] || continue
    mkdir -p "$HOME/$(dirname "$path")"
    retire "$HOME/$path"
    mv "$STAGE/$path" "$HOME/$path" || say "\e[31;01mCould not install ~/$path\e[00m"
done <<<"$manifest"

#  +-+-+-+-+-+-+-+
#  |.|b|a|s|h|r|c|
#  +-+-+-+-+-+-+-+
# Written at most once. From then on it belongs to the user and updates skip it.

BASHRC="$HOME/.bashrc"
[[ -L $BASHRC ]] && BASHRC=$(readlink -f "$BASHRC")

emishrc_block() {
    # The managed block only, pulled out of the template.
    sed -n "/^${BLOCK_START}\$/,/^${BLOCK_END}\$/p"
}

if [[ -e $BASHRC ]] && grep -qF "$BLOCK_START" "$BASHRC"; then
    say "\e[32;01m~/.bashrc already loads emishrc, leaving it alone.\e[00m"
elif [[ -e $BASHRC ]] && grep -q '^export _RCVERSION=' "$BASHRC" && grep -q '^function check_updates' "$BASHRC"; then
    ## Pre-48 layout: the whole monolith lived in ~/.bashrc. Retire it.
    backup="$BASHRC.pre-emishrc-$(date +%Y%m%d%H%M%S)"
    cp -p "$BASHRC" "$backup" 2>/dev/null
    cp "$STAGE/bashrc-template" "$BASHRC" || die "Could not write $BASHRC."
    say "\e[32;01mYour old ~/.bashrc was replaced by a small one you own; the previous one is at $backup\e[00m"
elif [[ -e $BASHRC ]]; then
    ## Somebody else's .bashrc (distro default, or hand written). Keep every
    ## line of it and only prepend our block at the very top.
    backup="$BASHRC.pre-emishrc-$(date +%Y%m%d%H%M%S)"
    cp -p "$BASHRC" "$backup" 2>/dev/null
    {
        emishrc_block < "$STAGE/bashrc-template"
        echo ""
        cat "$backup"
    } > "$BASHRC.emishrc-new" && mv "$BASHRC.emishrc-new" "$BASHRC" || die "Could not write $BASHRC."
    say "\e[32;01memishrc was prepended to your existing ~/.bashrc (backup at $backup)\e[00m"
else
    cp "$STAGE/bashrc-template" "$BASHRC" || die "Could not write $BASHRC."
    say "\e[32;01mCreated ~/.bashrc\e[00m"
fi

#  +-+-+-+-+-+-+-+-+-+-+-+
#  |.|b|a|s|h|_|c|u|s|t|o|m|
#  +-+-+-+-+-+-+-+-+-+-+-+
# ~/.bashrc now plays the role .bash_custom used to, so fold it in and retire it.

CUSTOM="$HOME/.bash_custom"
if [[ -s $CUSTOM ]] && ! grep -qF "$MIGRATION_MARK" "$BASHRC" 2>/dev/null; then
    {
        echo ""
        echo "$MIGRATION_MARK"
        sed '1{/^#!/d}' "$CUSTOM"
        echo "# --- end of migrated ~/.bash_custom ---"
    } >> "$BASHRC"
    mv -f "$CUSTOM" "$CUSTOM.migrated"
    say "\e[32;01m~/.bash_custom was appended to ~/.bashrc and renamed to ~/.bash_custom.migrated\e[00m"
fi

#  +-+-+-+-+-+-+-+-+-+-+-+-+
#  |.|b|a|s|h|_|p|r|o|f|i|l|e|
#  +-+-+-+-+-+-+-+-+-+-+-+-+
# Login shells (ssh, tty, Termux) read .bash_profile and, if it exists, never
# read .bashrc on their own. Make sure it chains.

ADD_TO_BASH_PROFILE=0
## A login shell sources only the FIRST of these that exists, so that is the one
## that has to chain to .bashrc. If none exists, bash reads nothing at all.
login_rc=""
for candidate in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do
    [[ -e $candidate ]] && { login_rc=$candidate; break; }
done

if [[ -z $login_rc ]] || ! grep -q '\.bashrc' "$login_rc"; then
    answer=n
    target=${login_rc:-$HOME/.bash_profile}
    if [[ $QUIET == false && -r /dev/tty ]]; then
        echo -e "\e[33;01m$(basename "$target") does not source .bashrc, so login shells (ssh, tty, Termux) would skip it. Add it? [Y/n]\e[00m"
        read -r answer < /dev/tty
        [[ -z $answer ]] && answer=y
    fi
    if [[ $answer == y || $answer == Y ]]; then
        {
            echo ""
            echo "# Source the .bashrc file"
            echo "if [ -f ~/.bashrc ]; then"
            echo "  source ~/.bashrc"
            echo "fi"
        } >>"$target"
        say "\e[32;01m.bashrc sourcing added to $target\e[00m"
        ADD_TO_BASH_PROFILE=1
    fi
fi

if [[ $QUIET == false && $SHELL != */bash ]]; then
    if command -v chsh >/dev/null 2>&1 && chsh -s "$(command -v bash)"; then
        echo -e "\e[31;01mYOUR SHELL WAS CHANGED TO BASH. PLEASE LOG OUT AND LOG IN AGAIN FOR IT TO WORK!\e[00m"
    else
        echo -e "\e[31;01mCould not change your default shell to bash. Please do it manually.\e[00m"
    fi
fi

[[ $QUIET == true ]] && exit 0

#  +-+-+-+-+-+-+-+-+-+-+-+-+
#  |I|n|t|e|r|a|c|t|i|v|e| |e|x|t|r|a|s|
#  +-+-+-+-+-+-+-+-+-+-+-+-+

if command -v gio >/dev/null 2>&1; then
    echo -e "\e[32;01mEverything went well! Previous files are in the trash bin.\e[00m"
else
    echo -e "\e[32;01mEverything went well! Previous files (if any) were backed up with a .bak extension!\e[00m"
fi

ask() { # ask <prompt> <default y|n>
    local answer
    [[ -r /dev/tty ]] || return 1
    echo -en "$1"
    read -r answer < /dev/tty
    [[ -z $answer ]] && answer=$2
    [[ $answer == y || $answer == Y ]]
}

if command -v pacman >/dev/null 2>&1; then
    if ask "\e[34;01m\n\nBtw, you use Arch. Do you want to install a couple cool shit for this to work even better? [Y/n]\e[00m " y; then
        pkgs=(grc cowsay fortune-mod lolcat colordiff nano inetutils nano-syntax-highlighting bash-completion)
        if [[ $(id -u) -eq 0 ]]; then
            pacman -S --needed --noconfirm "${pkgs[@]}" sudo
        elif command -v sudo >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "${pkgs[@]}"
        else
            echo -e "\e[34;01mYou need sudo to install this. Install it and try again.\e[00m"
        fi
    fi
elif command -v apt >/dev/null 2>&1; then
    if ask "\e[34;01m\n\nI see you're not an Arch user, but at least it's linux. Do you want to install some software for this to work better? [Y/n]\e[00m " y; then
        pkgs=(grc cowsay fortune-mod lolcat colordiff nano bash-completion)
        if [[ $(id -u) -eq 0 ]]; then
            apt install "${pkgs[@]}" sudo
        elif command -v sudo >/dev/null 2>&1; then
            sudo apt install "${pkgs[@]}"
        else
            echo -e "\e[34;01mYou need sudo to install this. Install it and try again.\e[00m"
        fi
    fi
fi

## Nano syntax highlighting, without piling up duplicate includes on every run.
if command -v nano >/dev/null 2>&1 && ! grep -q '^include "\?/usr/share/nano' "$HOME/.nanorc" 2>/dev/null; then
    echo -e "\e[34;01mAdding syntax highlighting to nano...\e[00m"
    ## Let nano expand these globs when it starts. Writing one include per
    ## installed file leaves broken entries behind whenever a package removes
    ## or renames a syntax definition.
    for d in /usr/share/nano /usr/share/nano/extra /usr/share/nano-syntax-highlighting; do
        compgen -G "$d/*.nanorc" >/dev/null && echo "include \"$d/*.nanorc\"" >> "$HOME/.nanorc"
    done
fi

if ! { [[ $(id -u) -eq 0 ]] || command -v sudo >/dev/null 2>&1; }; then
    echo -e "\e[34;01mYou need to be root or have sudo to be able to get additional options. Run this script again with sudo or as root.\e[00m"
    exit 0
fi

as_root() { if [[ $(id -u) -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

if ask "\e[34;01m\nDo you want to have nanorc for the root user with different colors? [Y/n]\e[00m " y; then
    echo -e "\e[34;01mCopying .nanorc to /etc/nanorc...\e[00m"
    as_root cp "$HOME/.nanorc" /etc/nanorc
    as_root sed -i '/^## Colors for user/,/^####/d' /etc/nanorc
    as_root sed -i 's/^###//' /etc/nanorc
fi

if ask "\e[34;01m\nDo you want new users on this machine to automatically have emi's bashrc installed by default? [Y/n]\e[00m " y; then
    echo -e "\e[34;01mCopying files to /etc/skel...\e[00m"
    as_root rm -rf /etc/skel/.emishrc
    as_root cp -r "$HOME/.emishrc" "$HOME/.bash_completion" "$HOME/.dircolors" \
        "$HOME/.inputrc" "$HOME/.toprc" "$HOME/.grc" /etc/skel/
    ## New users get the small stub, never a copy of your personal .bashrc.
    as_root cp "$STAGE/bashrc-template" /etc/skel/.bashrc
    [[ -f /etc/nanorc ]] && as_root cp /etc/nanorc /etc/skel/.nanorc
    if [[ $ADD_TO_BASH_PROFILE -eq 1 ]]; then
        printf '\n# Source the .bashrc file\nif [ -f ~/.bashrc ]; then\n  source ~/.bashrc\nfi\n' |
            as_root tee -a /etc/skel/.bash_profile >/dev/null
    fi
fi

if ask "\e[34;01m\nDo you want to link all users' bash history to root's bash history, effectively sharing the history between all users? [y/N]\e[00m " n; then
    if [ -f "$HOME/.bash_eternal_history" ]; then
        echo -e "\e[34;01mBash history file already exists. Moving to /.bash_eternal_history.\e[00m"
        as_root mv "$HOME/.bash_eternal_history" /.bash_eternal_history
    else
        echo -e "\e[34;01mCreating bash history file in /.bash_eternal_history.\e[00m"
        as_root touch /.bash_eternal_history
    fi

    as_root chmod 777 /.bash_eternal_history
    as_root ln -sf /.bash_eternal_history /etc/skel/.bash_eternal_history
    as_root ln -sf /.bash_eternal_history "$HOME/.bash_eternal_history"

    if [ -n "$(ls -A /home 2>/dev/null)" ]; then
        for user_home in /home/*; do
            [ -d "$user_home" ] && as_root ln -sf /.bash_eternal_history "$user_home/.bash_eternal_history"
        done
        echo -e "\e[34;01mBash history linked for existing users in /home.\e[00m"
    else
        echo -e "\e[34;01mNo existing users found in /home to link bash history.\e[00m"
    fi
fi

echo -e "\e[34;01mThat's all! KTHXBYE\n\n\e[00m"
