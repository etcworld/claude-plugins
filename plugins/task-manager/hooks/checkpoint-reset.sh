#!/bin/bash
# Reset checkpoint counter after a checkpoint is performed
# This runs when task.md is edited (checkpoint indicator)

COUNTER_FILE="$HOME/.claude/task-manager/.tool-count"
echo "0" > "$COUNTER_FILE"
