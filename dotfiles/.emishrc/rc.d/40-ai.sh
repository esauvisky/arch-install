#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.


function _gemini_query() {
    # 1. Kill Switch & Config Checks
    if [[ "$BASHRC_DISABLE_AI" -eq 1 ]]; then
        echo "AI features are disabled (BASHRC_DISABLE_AI=1)." >&2
        return 1
    fi

    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: GEMINI_API_KEY not set." >&2
        return 1
    fi

    if ! command -v jq >/dev/null || ! command -v curl >/dev/null; then
        echo "Error: 'jq' and 'curl' are required." >&2
        return 1
    fi

    local system_instruction="$1"
    local user_input="$2"

    # 2. Define the JSON Schema
    # This enforces that the LLM returns ONLY a JSON object with a "command" string.
    local response_schema='{
        "type": "OBJECT",
        "properties": {
            "command": {
                "type": "STRING",
                "description": "The precise bash command to execute."
            }
        },
        "required": ["command"]
    }'

    # 4. Construct JSON Payload
    local payload
    payload=$(jq -n \
              --arg sys "$system_instruction" \
              --arg usr "$user_input" \
              --argjson schema "$response_schema" \
              '{
                contents: [{
                  role: "user",
                  parts: [{text: ($sys + "\n\nUser Request: " + $usr)}]
                }],
                generationConfig: {
                    temperature: 0.1,
                    responseMimeType: "application/json",
                    responseSchema: $schema
                }
              }')

    # 5. Call Gemini API
    local response
    response=$(curl -s -X POST \
         -H "Content-Type: application/json" \
         "https://generativelanguage.googleapis.com/v1beta/models/${BASHRC_GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}" \
         -d "$payload")

    # 6. Extract and Parse Output
    # The API returns a JSON string inside 'text'. We must extract that string,
    # then parse it again to get the 'command' field.
    local cmd_output
    cmd_output=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty')

    if [[ -n "$cmd_output" && "$cmd_output" != "null" ]]; then
        # Parse the inner JSON to get the actual command string
        echo "$cmd_output" | jq -r '.command'
        return 0
    else
        # If debug is needed, uncomment the line below
        # echo "API Error or Empty Response: $response" >&2
        return 1
    fi
}

ask() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ask <question>"
        echo "Example: ask find all pdfs larger than 10MB and move them to /tmp"
        return 1
    fi

    local question="$*"
    local cmd

    # Call query function (System prompt is now internal to _gemini_query)
    if cmd=$(_gemini_query "$BASHRC_ASK_PROMPT" "$question"); then
        # Print the command in Cyan
        echo -e "\e[36m$cmd\e[0m"

        # Add logic to history
        history -s "ask $question"
        history -s "$cmd"

        echo "Press ↑ to recall command. Or type prompt + Ctrl+O."
    else
        echo "Failed to generate command." >&2
        return 1
    fi
}

__ask_ctrl_o() {
    local q="$READLINE_LINE"

    # Strip "ask " prefix if present
    if [[ "$q" == ask\ * ]]; then
        q="${q#ask }"
    fi

    # Trim whitespace
    q="${q#"${q%%[![:space:]]*}"}"
    q="${q%"${q##*[![:space:]]}"}"

    [[ -n "$q" ]] || return 0

    local cmd
    cmd="$(_gemini_query "$BASHRC_ASK_PROMPT" "$q")" || return 0

    # Replace readline buffer
    READLINE_LINE="$cmd"
    READLINE_POINT=${#READLINE_LINE}

    # History
    history -s "ask $q"
    history -s "$cmd"
}

bind -x '"\C-o":__ask_ctrl_o'
