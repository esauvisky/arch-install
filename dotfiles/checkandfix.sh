#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

# cd into this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"

echo "I need permissions to sync for everyone!"
sudo test true

for dir in /home/* "/etc/skel" "/root"; do
    if [[ ! -d "$dir" ]]; then
        echo -e "\n\n${dir} is not a directory. Skipping..."
    fi

    echo -e "\n\nChecking dotfiles at directory ${dir}"

    for i in ./.*; do
        if [[ -d ${i//\.\//} && (${i//\.\//} == '.' || ${i//\.\//} == '..') ]]; then
            # echo "Skipping $i"
            continue
        fi

        if [[ -d ${dir}/"${i//\.\//}"
            || ($(md5sum ${dir}/"${i//\.\//}" | cut -d' ' -f1) != $(md5sum "$i" | cut -d' ' -f1)) ]]; then
            echo "The files ${dir}/${i//\.\//} and ${i} arent the same or the latter is not a symlink."
            gio trash ${dir}/"${i//\.\//}"
            ln -s "$PWD/${i//\.\//}" ${dir}/"${i//\.\//}"
        fi

        if [[ ( -e ${dir}/"${i//\.\//}" && -L ${dir}/"${i//\.\//}" ) ]]; then
            echo "All good for $i, already symlinked"
        elif [[ ( -e ${dir}/"${i//\.\//}" && ! -L ${dir}/"${i//\.\//}" ) ]]; then
            if diff ${dir}/"${i//\.\//}" "$PWD/${i//\.\//}" -q; then
                echo "File ${i//\.\//} exits but is not a link, but contents are identical. Replacing..."
                gio trash ${dir}/"${i//\.\//}" || true
                ln -s "$PWD/${i//\.\//}" ${dir}/"${i//\.\//}"
            else
                echo "IDK WHAT TO DO! FILES DIFFER. GOOD LUCK! BB"
                exit 1
            fi
        fi

    done
done

cd "${DIR}"