#!/bin/bash
# Task Manager Checkpoint Reminder Hook
# This hook tracks tool calls and reminds Claude to checkpoint

TASK_MANAGER_DIR="$HOME/.claude/task-manager"
COUNTER_FILE="$TASK_MANAGER_DIR/.tool-count"
CHECKPOINT_INTERVAL=${CHECKPOINT_INTERVAL:-5}
STATE_FILE="$TASK_MANAGER_DIR/state.json"

# Ensure directory exists
mkdir -p "$TASK_MANAGER_DIR"

# Check if there's an active task
has_active_task() {
    if [ -f "$STATE_FILE" ]; then
        grep -q '"status": "in_progress"' "$STATE_FILE" 2>/dev/null
        return $?
    fi
    return 1
}

# Initialize counter if not exists
if [ ! -f "$COUNTER_FILE" ]; then
    echo "0" > "$COUNTER_FILE"
fi

# Read current count
COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Only output reminder if there's an active task and we hit the interval
if has_active_task && [ $((COUNT % CHECKPOINT_INTERVAL)) -eq 0 ]; then
    echo "CHECKPOINT_REMINDER"
fi
