# Task Manager Plugin

AI-powered task lifecycle management with session continuity for Claude Code.

## Overview

This plugin provides a complete task management system that:
- Creates and tracks tasks from various sources (manual, Jira, ideas)
- Enables session continuity across Claude Code sessions
- Archives completed tasks with full history
- Syncs task index with actual folder structure

## Installation

```bash
# Add marketplace
claude plugin marketplace add etcworld/claude-plugins

# Install plugin
claude plugin install task-manager@etcworld-plugins
```

## Data Location

All task data is stored in `~/.claude/task-manager/` - **not in your project directory**.

This means:
- Tasks are shared across all your projects
- Task data persists independent of any project
- No need to add `tasks/` to `.gitignore`

The plugin automatically creates the directory structure on first use.

## Commands

| Command | Description |
|---------|-------------|
| `/task-manager:create` | Create a new task from title, Jira ticket, or idea |
| `/task-manager:continue` | Resume work on an existing task |
| `/task-manager:complete` | Complete a task with user approval and archive it |
| `/task-manager:idea` | Quick capture an idea to backlog |
| `/task-manager:sync` | Synchronize index with task folders |

## Skills

The `task-lifecycle` skill automatically activates when you mention:
- "continue", "resume", "devam"
- "what was I working on"
- "last task", "kaldığım yer"

This provides seamless session continuity without explicit commands.

## Directory Structure

All data is stored in `~/.claude/task-manager/`:

```
~/.claude/task-manager/
└── tasks/
    ├── index.md           # Task index (auto-managed)
    ├── active/            # Active tasks
    │   └── TASK-XXX-slug/
    │       ├── task.md    # Task details
    │       ├── subtasks/  # Subtask files
    │       ├── context/   # Context files (session-persistent)
    │       └── outputs/   # Task outputs
    ├── completed/         # Archived completed tasks
    ├── cancelled/         # Cancelled tasks
    ├── backlog/
    │   ├── ideas.md       # Quick ideas list
    │   └── *.md           # Detailed idea files
    └── templates/
        ├── task.md        # Task template
        └── idea.md        # Idea template
```

**Note:** This structure is created automatically when you first use the plugin.

## Usage Examples

### Create a Task

```bash
# From title
/task-manager:create "Implement user authentication"

# From Jira ticket
/task-manager:create --from-jira AT-12345

# From backlog idea
/task-manager:create --from-idea continuous-profiling
```

### Continue Working

```bash
# Resume specific task
/task-manager:continue TASK-007

# List active tasks and choose
/task-manager:continue
```

### Quick Idea Capture

```bash
# Quick capture
/task-manager:idea "Add dark mode support"

# Detailed with priority
/task-manager:idea "Implement distributed tracing" --detailed --priority HIGH
```

### Complete a Task

```bash
# Complete with approval
/task-manager:complete TASK-007

# Force complete (with incomplete items)
/task-manager:complete TASK-007 --force
```

### Sync Index

```bash
# Check discrepancies
/task-manager:sync

# Auto-fix discrepancies
/task-manager:sync --fix
```

## Task Lifecycle

```
/task-manager:idea "New feature"          → Captured in backlog
         ↓
/task-manager:create --from-idea          → Converts to active task
         ↓
/task-manager:continue TASK-XXX           → Work on task
         ↓
/task-manager:complete TASK-XXX           → Archive completed task
```

## Features

### Session Continuity (Context-Safe)

**Problem:** Claude Code's context window can fill up, causing session resets and loss of working memory.

**Solution:** This plugin ensures all progress is persistently saved to disk:

- **Disk is source of truth** - Never rely on conversation history alone
- **Checkpoint after every step** - Progress written to `task.md` immediately
- **Context folder for large data** - Research, decisions, code analysis stored separately
- **Clear position markers** - `[NEXT]`, `[IN_PROGRESS]`, `[COMPLETED]` tags
- **Session recovery** - New session can resume from exact point using disk state

```
~/.claude/task-manager/tasks/active/TASK-XXX/
├── task.md           # Current state + position markers
├── context/
│   ├── research.md   # Findings (survives context clear)
│   └── decisions.md  # Decision log (survives context clear)
├── subtasks/         # Individual subtask tracking
└── outputs/          # Deliverables
```

### Jira Integration
- Import tasks directly from Jira tickets
- Maintains link to source ticket
- Syncs with `/ai-developer` workflow

### Idea Backlog
- Quick capture mode for fast idea logging
- Detailed mode for well-thought ideas
- Priority levels (HIGH/MEDIUM/LOW)
- Easy conversion to active tasks

### Index Management
- Automatic index synchronization
- Detects discrepancies between folders and index
- Safe operations (never deletes folders)

## Requirements

- Claude Code CLI
- Optional: Atlassian MCP for Jira integration

## License

MIT

## Author

etcworld (etcworld@gmail.com)
