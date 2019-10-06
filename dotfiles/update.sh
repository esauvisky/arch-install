#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

for i in ./.*; do
    if [[ -e ~/"${i//\.\//}" && $(md5sum ~/"${i//\.\//}" | cut -d' ' -f1) != $(md5sum "$i" | cut -d' ' -f1) ]]; then
        if [[ -f ~/"${i//\.\//}" ]]; then
            echo 'Whops, file '~/"${i//\.\//}"' is not a symlink to this repo! Check it out manually!'
            return 1
        fi
        echo 'Updating ~/'"${i//\.\//}..."
        gio trash ~/"${i//\.\//}"
        ln -s ./ ~/"${i//\.\//}"
    fi
done
