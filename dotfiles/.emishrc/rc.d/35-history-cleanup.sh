#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
##  |B|a|s|h| |H|i|s|t|o|r|y| |C|l|e|a|n|u|p|
##  +-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+
## Cleans up your bash history file by removing duplicates and the top 5% long entries.
cleanup_bash_history() {
    local file="$HOME/.bash_eternal_history"
    if [[ ! -f "$file" ]]; then
        echo "No history file found at $file. Nothing to do."
        return
    elif ! _e "awk" || ! _e "sort" || ! _e "head" || ! _e "cut" || ! _e "wc"; then
        echo "awk, sort, head, cut, and wc are required for this function."
        return
    fi

    # Temporary files for our intermediate data.
    local tmp_blocks tmp_info tmp_new tmp_remove_ids tmp_final
    tmp_blocks=$(mktemp) || return 1
    tmp_info=$(mktemp) || return 1
    tmp_new=$(mktemp) || return 1
    tmp_remove_ids=$(mktemp) || return 1
    tmp_final=$(mktemp) || return 1

    total_commands=$(grep -c '^#[0-9][0-9]*$' "$file")
    five_percent=$((total_commands/20))

    echo "Before cleanup, history file size: $(wc -c < "$file") bytes."
    echo "Total commands: $total_commands. Will remove the longest $five_percent."

    # Step 1. Split the file into command blocks.
    # Each block starts with a timestamp line (a line that starts with '#' and digits)
    # and includes all following lines until the next timestamp line.
    # We write each block to tmp_blocks with markers and also output block id and its length.
    awk -v out_blocks="$tmp_blocks" -v out_info="$tmp_info" '
        BEGIN { block_id = 0; block = "" }
        # When a line looks like a timestamp line…
        /^#[0-9]+$/ {
        # If we already have a block, output it first.
        if (block != "") {
            print "BLOCKSTART " block_id >> out_blocks
            printf "%s", block >> out_blocks
            print "BLOCKEND" >> out_blocks
            # Record block id and its length (number of characters).
            print block_id "\t" length(block) >> out_info
        }
        block_id++
        block = $0 "\n"
        next
        }
        # Otherwise, continue appending to the current block.
        { block = block $0 "\n" }
        END {
        if (block != "") {
            print "BLOCKSTART " block_id >> out_blocks
            printf "%s", block >> out_blocks
            print "BLOCKEND" >> out_blocks
            print block_id "\t" length(block) >> out_info
        }
        }
    ' "$file"

    # Step 2. Find the blocks with the greatest character count.
    # Sort descending by length (field 2), pick top $five_percent, and extract the block ids.
    sort -k2,2nr "$tmp_info" | head -n "$five_percent" | cut -f1 > "$tmp_remove_ids"

    # Step 3. Reassemble the history file, skipping blocks whose id is in the removal list.
    # We read the file we generated with block markers.
    awk -v remove_ids_file="$tmp_remove_ids" '
        BEGIN {
        # Read the list of block ids to remove into an array.
        while (getline id < remove_ids_file) {
            remove[id] = 1
        }
        in_block = 0
        skip = 0
        }
        # Identify the start of a block.
        /^BLOCKSTART/ {
        in_block = 1
        split($0, a, " ")
        current_id = a[2]
        skip = (current_id in remove)
        # Print the block content (including the timestamp) only if not skipping.
        next
        }
        # Identify the end of a block.
        /^BLOCKEND/ {
        in_block = 0
        skip = 0
        next
        }
        # For lines inside a block, print them only if we are not skipping.
        {
        if (in_block && !skip) print
        }
    ' "$tmp_blocks" > "$tmp_new"

    echo "After long-entry removal, history file size: $(wc -c < "$tmp_new") bytes."

    # Step 4. Remove duplicate commands, keeping only the latest usage.
    # Here, we treat a "block" as starting with a timestamp line (matching ^#[0-9]+$)
    # followed by one or more lines (the command itself). We compare the command portion (i.e. all lines except the first)
    # and if duplicates are found, only the last occurrence is kept.
    awk '
        # Helper function to trim whitespace.
        function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }

        # When a line is a timestamp line, it signals the start of a new block.
        /^#[0-9]+$/ {
        if (block != "") {
            blocks[++n] = block
            # Split block into lines; assume first line is timestamp.
            num = split(block, arr, "\n")
            cmd = ""
            for(i = 2; i <= num; i++) {
            cmd = cmd arr[i] "\n"
            }
            commands[n] = trim(cmd)
        }
        block = $0 "\n"
        next
        }
        { block = block $0 "\n" }
        END {
        if (block != "") {
            blocks[++n] = block
            num = split(block, arr, "\n")
            cmd = ""
            for(i = 2; i <= num; i++) {
            cmd = cmd arr[i] "\n"
            }
            commands[n] = trim(cmd)
        }
        # Process blocks in reverse order so that the first time we encounter a command (from the bottom)
        # is its latest occurrence.
        for(i = n; i >= 1; i--) {
            if (!(commands[i] in seen)) {
            keep[i] = 1
            seen[commands[i]] = 1
            } else {
            keep[i] = 0
            }
        }
        # Output blocks in the original order (chronologically) if marked to keep.
        for(i = 1; i <= n; i++) {
            if (keep[i])
            printf "%s", blocks[i]
        }
        }
    ' "$tmp_new" > "$tmp_final"

    echo "After duplicate removal, history file size: $(wc -c < "$tmp_final") bytes."

    echo "Backing up $file to $file.bak"
    cp "$file" "$file.bak"
    echo "Moving cleaned file to $file"
    cp "$tmp_final" "$file"

    command rm -f "$tmp_blocks" "$tmp_info" "$tmp_new" "$tmp_remove_ids" "$tmp_final"

    echo "Done. Restart your shells or they will overwrite the new history file with the old one."
}
