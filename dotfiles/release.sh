#!/usr/bin/env bash
# Regenerates .emishrc/MANIFEST and stamps the legacy update marker in .bashrc
# from .emishrc/VERSION. Run it from this directory after bumping VERSION.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

version=$(tr -cd '0-9' < .emishrc/VERSION)
[[ -n $version ]] || { echo "VERSION is empty or not a number" >&2; exit 1; }

## Files the installer pulls down, relative to dotfiles/, one per line.
## ~/.bashrc is deliberately absent: it is installed once and never updated.
{
    printf '%s\n' .emishrc/VERSION .emishrc/init.sh .emishrc/update.sh
    find .emishrc/rc.d -name '*.sh' -type f | sort
    printf '%s\n' .bash_completion .dircolors .inputrc .toprc .nanorc .git_prompt.sh
    find .grc -type f | sort
} > .emishrc/MANIFEST

## Old (<= 47) clients grep the remote .bashrc for `export _RCVERSION=`, so the
## template carries an inert comment that their sed still parses into a number.
sed -i -E "s|^(# emishrc legacy update marker, do not remove: export _RCVERSION=)[0-9]+$|\1${version}|" .bashrc
grep -q "export _RCVERSION=${version}$" .bashrc || { echo "failed to stamp legacy marker in .bashrc" >&2; exit 1; }

echo "release $version: $(wc -l < .emishrc/MANIFEST) files in MANIFEST, legacy marker stamped"
