#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to copy the actual file if it's a symlink
copy_file() {
    local src_file="$1"
    local dest_file="$2"

    if [ ! -e "$src_file" ]; then
        echo -e "${RED}Source file does not exist: $src_file${NC}"
        return
    fi

    if [ -L "$src_file" ]; then
        # If it's a symlink, get the actual file
        actual_file=$(readlink -f "$src_file")
        if [ ! -e "$actual_file" ]; then
            echo -e "${RED}Actual file for symlink does not exist: $actual_file${NC}"
            return
        fi
        if [ "$actual_file" -ef "$dest_file" ]; then
            echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - Success: Symlink target $actual_file is the same as local target $dest_file${NC}"
        else
            mkdir -p "$(dirname "$dest_file")"
            if cp "$actual_file" "$dest_file"; then
                echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - Successfully copied symlink target $actual_file to $dest_file${NC}"
            else
                echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Error copying $actual_file to $dest_file${NC}"
            fi
        fi
    else
        # If it's not a symlink, copy the file directly
        mkdir -p "$(dirname "$dest_file")"
        if cp "$src_file" "$dest_file"; then
            echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - Successfully copied $src_file to $dest_file${NC}"
        else
            echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Error copying $src_file to $dest_file${NC}"
        fi
    fi
}

# Function to sync files from a source directory to a target directory
sync_files() {
    local source_dir="$1"
    local target_dir="$2"

    git ls-files "$target_dir" | while read -r target_file; do
        # Get the relative path of the target file
        relative_path="${target_file#$target_dir/}"

        # Define the source file path
        source_file="$source_dir/$relative_path"

        # Check if the source file exists and is not a symlink
        if [ ! -e "$source_file" ]; then
            echo -e "${RED}Source file does not exist: $source_file${NC}"
            continue
        fi

        # Ensure the target directory exists
        if [ ! -d "$(dirname "$target_file")" ]; then
            echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Target directory does not exist: $(dirname "$target_file")${NC}"
            continue
        fi

        # Sync the file from source to target
        copy_file "$source_file" "$target_file"
    done
}

# Sync files for each category
sync_files "$HOME/.config" "config"
sync_files "$HOME" "dotfiles"
sync_files "/etc" "etc"
