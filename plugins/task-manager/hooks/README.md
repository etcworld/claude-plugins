# Task Manager Hooks

Automatic checkpoint reminders to prevent context loss.

## How It Works

Hooks are **automatically configured** when the plugin is installed via `plugin.json`.

1. **checkpoint-reminder.sh** - Counts tool calls, triggers reminder every N calls
2. **checkpoint-reset.sh** - Resets counter when task.md is edited (checkpoint performed)

## What Gets Triggered

| Event | Hook | Action |
|-------|------|--------|
| Read, Grep, Glob, Bash, LSP call | checkpoint-reminder.sh | Increment counter, remind at interval |
| Edit task.md | checkpoint-reset.sh | Reset counter to 0 |

## How Reminders Work

1. Every tool call (Read, Grep, Glob, Bash, LSP) increments counter
2. When counter hits interval (default 5), reminder is injected
3. When task.md is edited (checkpoint), counter resets to 0
4. Reminders only appear if there's an active task (status: in_progress)

## Example Flow

```
Tool 1: Read file.go          # counter: 1
Tool 2: Grep pattern          # counter: 2
Tool 3: Read another.go       # counter: 3
Tool 4: Bash command          # counter: 4
Tool 5: Read config.yaml      # counter: 5 → REMINDER INJECTED

Claude checkpoints → Edit task.md → counter reset to 0

Tool 6: Read test.go          # counter: 1
...
```

## Configuration

### Checkpoint Interval

Default: Every 5 tool calls

To change, set environment variable before starting Claude:
```bash
export CHECKPOINT_INTERVAL=3
```

Or modify the script directly:
```bash
# In checkpoint-reminder.sh, change:
CHECKPOINT_INTERVAL=${CHECKPOINT_INTERVAL:-5}  # to desired value
```

## Troubleshooting

### Reminders not appearing

1. Check state.json has in_progress task:
   ```bash
   grep in_progress ~/.claude/task-manager/state.json
   ```

2. Check counter file:
   ```bash
   cat /tmp/claude-task-manager-tool-count
   ```

### Too many/few reminders

Adjust CHECKPOINT_INTERVAL in the script or via environment variable.

### Reset counter manually

```bash
echo "0" > /tmp/claude-task-manager-tool-count
```

## Technical Details

- Counter stored at: `~/.claude/task-manager/.tool-count`
- Hooks defined in: `.claude-plugin/plugin.json`
- Scripts location: `hooks/` directory
