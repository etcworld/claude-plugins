---
description: Resume work on an existing task
argument-hint: <TASK-ID>
---

# Task Continue Workflow

Version: 1.1.0
Last Updated: 2026-01-28

## Purpose

Resume work on an existing task by reading its current state, understanding progress, and continuing from where it left off. This enables session continuity across Claude Code sessions.

**IMPORTANT:** Only ONE task can be `in_progress` at a time. When switching to a new task, the current in_progress task is automatically set to `paused`.

---

## Task Status Flow

```
pending → in_progress → completed
            ↓    ↑
          paused
```

- `pending` - Not started yet
- `in_progress` - Currently active (only ONE allowed)
- `paused` - Was in_progress, switched to another task
- `completed` - Done

---

## Input

```
/task-manager:continue TASK-007
/task-manager:continue TASK-011-integration-test-cleanup
```

Accepts:
- Task ID only: `TASK-007`
- Full folder name: `TASK-011-integration-test-cleanup`

---

## Execution Steps

### Step 1: Parse Task ID

Extract TASK-ID from $ARGUMENTS:
- If full folder name given, extract ID portion
- Validate format: `TASK-XXX` where XXX is numeric

### Step 2: Locate Task via State

```bash
# Read state.json for fast lookup
Read: ~/.claude/task-manager/state.json

# Search in state.tasks.active first
task = state.tasks.active.find(t => t.id === "TASK-XXX")
if (task) {
  TASK_STATUS = "active"
  TASK_DIR = ~/.claude/task-manager/tasks/active/TASK-XXX-<task.slug>/
}

# If not found, check completed
if (!task) {
  task = state.tasks.completed.find(t => t.id === "TASK-XXX")
  if (task) {
    TASK_STATUS = "completed"
    TASK_DIR = ~/.claude/task-manager/tasks/completed/TASK-XXX-<task.slug>/
  }
}

# Fallback to filesystem if not in state
if (!task) {
  TASK_DIR=$(ls -d ~/.claude/task-manager/tasks/active/TASK-XXX-* 2>/dev/null | head -1)
}
```

### Step 3: Read Task Context

Read the following files:

```bash
# Main task file
Read: <TASK_DIR>/task.md

# Check for subtasks
ls <TASK_DIR>/subtasks/

# Check for context files
ls <TASK_DIR>/context/

# Check for outputs
ls <TASK_DIR>/outputs/
```

### Step 4: Analyze Task State

From task.md, extract:
- **Durum**: pending | in_progress | waiting_approval | completed
- **Son Güncelleme**: Last activity date
- **Plan**: Checklist with completion status
- **Subtasklar**: Table with subtask statuses
- **İlerleme Notları**: Recent progress notes

### Step 5: Analyze Subtasks

For each subtask in `subtasks/`:
```bash
Read: <TASK_DIR>/subtasks/XXX-*.md
```

Identify:
- Completed subtasks (durum: completed)
- In-progress subtasks (durum: in_progress)
- Pending subtasks (durum: pending)

### Step 6: Determine Resume Point

Based on analysis:

| Condition | Resume Action |
|-----------|---------------|
| Task is `completed` | Inform user, ask if they want to reopen |
| Task is `waiting_approval` | Ask user to approve or provide feedback |
| Task is `in_progress` with incomplete subtasks | Continue from first incomplete subtask |
| Task is `pending` | Start from beginning of plan |

### Step 7: Pause Current In-Progress Task (if any)

**CRITICAL:** Only one task can be `in_progress` at a time.

```bash
# Check for existing in_progress task
current_task = state.tasks.active.find(t => t.status === "in_progress")

if (current_task && current_task.id !== "TASK-XXX") {
  # Pause the current task
  current_task.status = "paused"
  current_task.updated = "<YYYY-MM-DD>"

  # Update its task.md
  Edit: ~/.claude/task-manager/tasks/active/<current_task folder>/task.md
  Change: "- **Durum:** in_progress" to "- **Durum:** paused"

  # Notify user
  Output: "**Note:** TASK-YYY paused (was in_progress)"
}
```

### Step 8: Update Task Status

If task was `pending` or `paused`, update to `in_progress`:

```bash
# Update task.md
Edit: <TASK_DIR>/task.md
Change: "- **Durum:** pending" to "- **Durum:** in_progress"
# OR
Change: "- **Durum:** paused" to "- **Durum:** in_progress"
Update: "- **Son Güncelleme:** <current datetime>"
```

**Also update state.json:**

```bash
# 1. Backup state
Copy: state.json → state.backup.json

# 2. Update task status in state
task = state.tasks.active.find(t => t.id === "TASK-XXX")
task.status = "in_progress"
task.updated = "<YYYY-MM-DD>"
state.lastUpdated = "<ISO-8601 timestamp>"

# 3. Write state
Write: ~/.claude/task-manager/state.json
```

### Step 9: Add Progress Note

Append to İlerleme Notları section:

```markdown
### <current date>
- Session resumed
- Current focus: <next incomplete item>
```

### Step 10: Output Summary

```markdown
## Task Resumed: TASK-XXX

**Title:** <task title>
**Status:** <durum>
**Last Updated:** <son güncelleme>
**Location:** <task dir>

### Current Progress
- Plan: X/Y items completed
- Subtasks: A completed, B in progress, C pending

### Subtasks (if any exist)
| ID | Title | Status |
|----|-------|--------|
| 001 | <subtask title> | completed |
| 002 | <subtask title> | in_progress |
| 003 | <subtask title> | pending |

**Next subtask:** 002 - <title>

### Resume Point
<Next action to take based on Step 6 analysis>

### Recent Progress Notes
<Last 2-3 progress entries>

---
Ready to continue. What would you like to work on?

**Subtask commands:**
- `/task-manager:subtask add TASK-XXX "title"` - Add new subtask
- `/task-manager:subtask done TASK-XXX 002` - Mark subtask done
- `/task-manager:subtask list TASK-XXX` - List all subtasks
```

---

## CRITICAL: Working Protocol After Continue

Once a task is resumed, Claude MUST follow these rules:

### Rule 1: Disk is Source of Truth
- **Always read from task.md** before making decisions
- **Never rely on conversation history** for task state
- Context can be cleared anytime - disk persists

### Rule 2: Checkpoint After Every Step
After completing any significant work:
```bash
# Update task.md with progress
Edit: <TASK_DIR>/task.md
Add to İlerleme Notları:
### YYYY-MM-DD HH:MM
- [COMPLETED] <what was just done>
- [NEXT] <immediate next step>
```

### Rule 3: Use Context Folder for Large Data
```bash
# Research findings
Write: <TASK_DIR>/context/research.md

# Important decisions
Write: <TASK_DIR>/context/decisions.md

# Code analysis
Write: <TASK_DIR>/context/code-analysis.md
```

### Rule 4: Mark Current Position
Always maintain a clear `[IN_PROGRESS]` or `[NEXT]` marker:
```markdown
## Plan
1. [x] Analysis ✅
2. [x] Design ✅
3. [ ] Implementation ← [IN_PROGRESS]
4. [ ] Testing
```

### Rule 5: Announce Checkpoints
When saving progress, inform the user:
```markdown
**Checkpoint saved** - Progress written to task.md
```

---

## Special Cases

### Jira-Linked Tasks

If task.md contains `Kaynak: jira:<TICKET-ID>`:

```markdown
### Jira Integration
This task is linked to **<TICKET-ID>**.
You can check the Jira ticket for additional context.
```

### Completed Tasks

If task is in `~/.claude/task-manager/tasks/completed/`:

```markdown
## Task Already Completed

**TASK-XXX** was completed on <date>.

Options:
1. View task details (read-only)
2. Reopen task (move back to active)
3. Create follow-up task with `/task-manager:create`
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Task ID not found | List available tasks, ask user to choose |
| Multiple matches | Show matches, ask user to specify |
| Task file corrupted | Show raw content, ask user how to proceed |
| No arguments | Show list of active tasks |

---

## No Arguments Behavior

When called without arguments:

```bash
/task-manager:continue
```

Output list of active tasks:

```markdown
## Active Tasks

| ID | Title | Status | Last Updated |
|----|-------|--------|--------------|
| TASK-007 | Reverse Identity Catchup | in_progress | 2025-01-15 |
| TASK-011 | Integration Test Cleanup | in_progress | 2025-01-05 |

Run `/task-manager:continue <TASK-ID>` to resume a specific task.
```

---

## Example Output

```
User: /task-manager:continue TASK-007

## Task Resumed: TASK-007

**Title:** Reverse Identity Catchup Job
**Status:** in_progress
**Last Updated:** 2025-01-15
**Location:** ~/.claude/task-manager/tasks/active/TASK-007-reverse-identity-catchup/

### Current Progress
- Plan: 2/5 items completed
- Subtasks: 1 completed, 1 in progress, 2 pending

### Resume Point
Continue with subtask 002: "Implement batch processing logic"
Currently at: Database query optimization

### Recent Progress Notes
**2025-01-15:**
- Started batch processing implementation
- Completed initial DB schema review

**2025-01-14:**
- Task created from JIRA AT-14200
- Initial analysis completed

---
Ready to continue. What would you like to work on?
```
