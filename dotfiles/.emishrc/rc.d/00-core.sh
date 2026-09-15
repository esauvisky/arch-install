#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.


## Returns if the current shell is a SSH shell.
# @see https://unix.stackexchange.com/a/12761
function is_ssh() {
    local p=${1:-$PPID}

    if [[ -n ${IS_SSH_CACHE[$p]} ]]; then
        return "${IS_SSH_CACHE[$p]}"
    fi

    if [[ ! -f /proc/1/stat ]]; then
        IS_SSH_CACHE[$p]=1
        return 1
    fi

    read -r pid name x ppid y < <(cat "/proc/$p/stat")
    # or: read pid name ppid < <(ps -o pid= -o comm= -o ppid= -p $p)

    if [[ "$name" =~ sshd ]]; then
        IS_SSH_CACHE[$p]=0
        return 0
    fi

    if [[ "$ppid" -le 1 ]]; then
        IS_SSH_CACHE[$p]=1
        return 1
    fi

    is_ssh "$ppid"
    local result=$?
    IS_SSH_CACHE[$p]=$result
    return $result
}

## Checks if a binary or built-in command exists on PATH with failovers
function _e() {
    type -P "$1" >/dev/null 2>&1 && return 0 # better for windows
    # hash "$@" >/dev/null 2>&1 && return 0
    return 1
}

export BASHRC_DISABLE_AI=0
export BASHRC_ASK_PROMPT="You are an expert DevOps and Bash scripting assistant.
Your goal is to translate natural language requests into precise, efficient, and safe one-liner Bash commands.

RULES:
1. QUOTING: You must be extremely careful with quotes. Always quote variables (e.g., \"\$VAR\") and filenames to handle spaces or special characters correctly.
2. SAFETY: Do not generate commands that blindly destroy data (like 'rm -rf /') unless the user explicitly and clearly asks for a destructive action on a specific path.
3. FORMAT: Output valid JSON only.
4. COMPLEXITY: Prefer readable one-liners. Use '&&' for chaining operations.

Return the result strictly adhering to the JSON schema provided."
export BASHRC_GEMINI_MODEL="gemini-3-flash-preview"

###  _____           _                                      _     _   _            _       _     _
### |  ___|         (_)                                    | |   | | | |          (_)     | |   | |
### | |__ _ ____   ___ _ __ ___  _ __  _ __ ___   ___ _ __ | |_  | | | | __ _ _ __ _  __ _| |__ | | ___  ___
### |  __| '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __| | | | |/ _` | '__| |/ _` | '_ \| |/ _ \/ __|
### | |__| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_  \ \_/ / (_| | |  | | (_| | |_) | |  __/\__ \
### \____/_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|  \___/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
## Asks for Ctrl+D to be pressed twice to exit the shell
export IGNOREEOF=1

# Check if the directories exist and add them to the PATH if they do
for dir in "$HOME/.local/bin" "$HOME/.yarn/bin" "$HOME/.bin" "$HOME/.cargo/bin" "$HOME/.npm-global/bin"; do
    if [[ -d $dir && ! "$PATH" =~ (^|:)"$dir"(:|$) ]]; then
        export PATH="$PATH:$dir"
    fi
done


## Picks a hostname variable to use all around
## Works on several places including adb shells and ssh
_ENV_COLOR='\[\e[22;37m\]'
_HOSTNAME=$(hostname)
if _e "getprop"; then
    # ADB shells
    _HOSTNAME=${_HOSTNAME:-$(getprop "net.hostname")}
    _HOSTNAME=${_HOSTNAME:-$(getprop "ro.product.device")}

    if [[ -n "$_HOSTNAME" ]]; then
        _HOSTNAME+=" [ADB]"
        _ENV_COLOR='\[\e[00;91m\]'
    fi
elif [[ -n "$_HOSTNAME" ]] && is_ssh; then
    # SSH shells
    _HOSTNAME+=" [SSH]"
    _ENV_COLOR='\[\e[01;93m\]'
fi

## GPG Signing TTY: required for GPG signing in git
GPG_TTY=$(tty)
export GPG_TTY

## This fixes a bug that happens when calling `sudo su USER`
## inside a SSH shell that keeps loginctl envvars making some commands not work.
## @see https://unix.stackexchange.com/questions/346841/why-does-sudo-i-not-set-xdg-runtime-dir-for-the-target-user
if [[ -z $XDG_RUNTIME_DIR && $(is_ssh) ]]; then
    export XDG_RUNTIME_DIR=/run/user/$UID
fi

## Sets default EDITOR environment variable
## If logged as root or in a ssh shell uses only term editors.
_e "nano" && export EDITOR="nano"
if [[ -n $DISPLAY && ! $EUID -eq 0 && ! $(is_ssh) ]]; then
    for editor in "subl3" "subl" "code" "gedit"; do
        _e "$editor" && export EDITOR=$editor
    done
fi

## Android shit
if [[ -d $ANDROID_NDK ]]; then
    export ANDROID_NDK_ROOT="$ANDROID_NDK"
    export ANDROID_NDK_HOME="$ANDROID_NDK"
fi

if [[ -d "/opt/android-sdk" ]]; then
    export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:="/opt/android-sdk"}
    export ANDROID_HOME=${ANDROID_HOME:=$ANDROID_SDK_ROOT}

    if [[ -d $ANDROID_HOME ]]; then
        # adds build tools (aapt, dexdump, etc)
        # only adds the highest version
        build_tools="$(find "$ANDROID_HOME/build-tools" -maxdepth 1 -type d | sort --numeric-sort --reverse | head -n1)"
        if [[ -d "$build_tools" ]]; then
            export PATH="$PATH:$build_tools"
        fi

        if [[ -d "$ANDROID_HOME/platform-tools" ]]; then
            export PATH="${PATH}:$ANDROID_HOME/platform-tools"
        fi
    fi
fi
