#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

for i in ./.*; do
    if [[ -f ~/"${i//\.\//}" && $(md5sum ~/"${i//\.\//}" | cut -d' ' -f1) != $(md5sum "$i" | cut -d' ' -f1) ]]; then
        rm "$i"
        cp ~/"${i//\.\//}" ./
    fi
done
