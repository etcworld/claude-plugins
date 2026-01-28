#!/bin/bash
# Reset checkpoint counter after a checkpoint is performed
# This runs when task.md is edited (checkpoint indicator)

# Read input from stdin (JSON with tool_input)
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Only reset counter if editing a task.md file
if [[ "$FILE_PATH" =~ task\.md$ ]]; then
    COUNTER_FILE="$HOME/.claude/task-manager/.tool-count"
    mkdir -p "$(dirname "$COUNTER_FILE")"
    echo "0" > "$COUNTER_FILE"
fi

exit 0
