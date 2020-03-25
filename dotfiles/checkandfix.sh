#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

for i in ./.*; do
    if [[ -d ${i//\.\//} && (${i//\.\//} == '.' || ${i//\.\//} == '..') ]]; then
        echo "Skipping $i"
        continue
    fi
    if [[ -d ~/"${i//\.\//}"
        || ($(md5sum ~/"${i//\.\//}" | cut -d' ' -f1) != $(md5sum "$i" | cut -d' ' -f1)) ]]; then
        echo "The files ~/${i//\.\//} and ${i} arent the same or the latter is not a symlink."
        echo "In case you need the file back, it's on your trash bin (deleted via gio trash, not rm)."
        echo 'Updating ~/'"${i//\.\//}..."
        gio trash ~/"${i//\.\//}" || true
        ln -s "$PWD/${i//\.\//}" ~/"${i//\.\//}"
    fi
    if [[ ( -e ~/"${i//\.\//}" && -L ~/"${i//\.\//}" ) ]]; then
        echo "All good for $i"
    elif [[ ( -e ~/"${i//\.\//}" && ! -L ~/"${i//\.\//}" ) ]]; then
        echo "File ${i//\.\//} exits but is not a link!"
        if diff ~/"${i//\.\//}" "$PWD/${i//\.\//}" -q; then
            echo "Will replace the link as contents are identical! :)"
            gio trash ~/"${i//\.\//}"
            ln -s "$PWD/${i//\.\//}" ~/"${i//\.\//}"
        else
            echo "IDK WHAT TO DO! FILES DIFFER.GOOD LUCK! BB"
            exit 1
        fi
    fi
done
