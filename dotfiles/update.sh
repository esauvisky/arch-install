#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

for i in ./.*; do
    if [[ -d ${i//\.\//} && (${i//\.\//} == '.' || ${i//\.\//} == '..') ]]; then
        continue
    fi
    if [[ -d ~/"${i//\.\//}" || $(md5sum ~/"${i//\.\//}" | cut -d' ' -f1) != $(md5sum "$i" | cut -d' ' -f1) || ( -e ~/"${i//\.\//}" && -L ~/"${i//\.\//}" ) ]]; then
        echo 'The files arent the same! Probably not a symlink.'
        echo 'Updating ~/'"${i//\.\//}..."
        gio trash ~/"${i//\.\//}" || true
        ln -s "$PWD/${i//\.\//}" ~/"${i//\.\//}"
    fi
done
