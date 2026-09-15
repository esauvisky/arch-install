#!/usr/bin/env bash
# shellcheck disable=SC2155,SC1090,SC1091
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.
#
# Version bookkeeping, changelog and the self-updater.

export _RCVERSION
_RCVERSION=$(< "$EMISHRC_DIR/VERSION")
_RCVERSION=${_RCVERSION//[^0-9]/}
export _DATE="September 15th, 2026"

## State lives in $HOME, not in $EMISHRC_DIR: the latter is wiped on every update.
_EMISHRC_STAMP="$HOME/.emishrc_last_check"
_EMISHRC_SEEN="$HOME/.emishrc_last_seen"
_EMISHRC_RAW="${EMISHRC_RAW:-https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles}"

function _changelog() {
    local a=$'\e[36;03m'       # cyan
    local r=$'\e[00m'          # reset
    local n=$'\e[07m'          # inverted bg
    local b=$'\e[1m'           # bold
    local y=$'\e[33;01m'       # yellow
    local i=$'\e[00m\e[96;03m' # emphasis
    local g=$'\e[32;01m'       # green
    local w=$'\e[97;01m'       # white bold
    local c=$'\e[97m'          # code
    local f=$'\e[5;91;01m'     # flashing red bold

    echo "${g}emi's .bashrc${r}
${y}Changelog $_RCVERSION ($_DATE)${r}" | sed -e :a -e "s/^.\{1,$(($(tput cols) + 10))\}$/ & /;ta"
    echo -e "
 ${a}Your ${c}~/.bashrc${r}${a} is yours now. Everything else lives in ${c}~/.emishrc/${r}${a}.${r}

  ${r}- ${b}${c}~/.bashrc${r}${b} is never overwritten again.${r}
    ${a}Updates only touch ${c}~/.emishrc/${r}${a}. Your old one was backed up next to it.${r}
    ${a}Installers that append to the bottom of ${c}~/.bashrc${r}${a} now survive updates,${r}
    ${a}and they run ${b}after${r}${a} emishrc, so your own settings always win.${r}

  ${r}- ${b}${c}~/.bash_custom${r}${b} is gone.${r}
    ${a}Its contents were appended to your ${c}~/.bashrc${r}${a} and the old file renamed${r}
    ${a}to ${c}~/.bash_custom.migrated${r}${a}. Put new customizations straight in ${c}~/.bashrc${r}${a}.${r}

  ${r}- ${b}The monolith was split into modules.${r}
    ${a}${c}~/.emishrc/rc.d/*.sh${r}${a} is sourced in filename order. Skip any of them with${r}
    ${a}${c}EMISHRC_SKIP=\"50-adb 85-python\"${r}${a}, or disable emishrc entirely with ${c}EMISHRC_DISABLE=1${r}${a}.${r}
  "
}

## Compares the local VERSION with the one in the repo and, if we're behind,
## re-runs the installer. Runs at most once a day, in the background.
function check_updates() {
    local now remote
    now=$(date +%s)

    if [[ -s "$_EMISHRC_STAMP" ]]; then
        local last
        last=$(< "$_EMISHRC_STAMP")
        [[ $((now - ${last//[^0-9]/})) -gt 86400 ]] || return 0
    fi
    echo "$now" >"$_EMISHRC_STAMP" 2>/dev/null || return 0

    remote=$(_emishrc_fetch "$_EMISHRC_RAW/.emishrc/VERSION")
    remote=${remote//[^0-9]/}
    [[ -n "$remote" ]] || return 0

    if [[ $((10#$remote - 10#${_RCVERSION:-0})) -gt 0 ]]; then
        command rm -f "$_EMISHRC_STAMP"
        _emishrc_fetch "$_EMISHRC_RAW/autoinstall.sh" | bash -s -- --quiet
    fi
}

## curl/wget wrapper: prints a URL to stdout, fails quietly.
function _emishrc_fetch() {
    if type -P curl >/dev/null 2>&1; then
        curl -fsSL -H "cache-control: no-cache" "$1" 2>/dev/null
    elif type -P wget >/dev/null 2>&1; then
        wget -q -O - "$1" 2>/dev/null
    else
        return 1
    fi
}
