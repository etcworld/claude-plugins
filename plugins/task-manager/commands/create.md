---
description: Create a new task from title or Jira ticket
argument-hint: <title> | --from-jira <TICKET-ID> | --from-idea <idea-slug>
---

# Task Create Workflow

Version: 1.0.0
Last Updated: 2025-01-18

## Purpose

Create a new task in the task management system. Supports three input modes:
1. **Manual**: Create from a title string
2. **Jira**: Import from a Jira ticket
3. **Idea**: Convert a backlog idea to a task

---

## Input Modes

### Mode 1: From Title (Default)
```
/task-manager:create "Implement user authentication"
```

### Mode 2: From Jira Ticket
```
/task-manager:create --from-jira AT-12345
```

### Mode 3: From Backlog Idea
```
/task-manager:create --from-idea continuous-profiling
```

---

## Execution Steps

### Step 1: Parse Arguments

Extract from $ARGUMENTS:
- Title string OR
- `--from-jira <TICKET-ID>` OR
- `--from-idea <idea-slug>`

### Step 2: Determine Next Task ID

```bash
# Find highest task number
ls ~/.claude/task-manager/tasks/active/ ~/.claude/task-manager/tasks/completed/ 2>/dev/null | grep -E "^TASK-[0-9]+" | sort -t- -k2 -n | tail -1
```

Calculate: `NEXT_ID = highest + 1`
Format: `TASK-XXX` (zero-padded to 3 digits)

### Step 3: Gather Task Information

**If from title:**
- Title = provided string
- Ask user for description if needed

**If from Jira:**
```
Tool: mcp__atlassian__getJiraIssue
Parameters:
  cloudId: "winsider.atlassian.net"
  issueIdOrKey: "<TICKET-ID>"
```
Extract: summary, description, type, priority

**If from idea:**
```bash
Read: ~/.claude/task-manager/tasks/backlog/<idea-slug>.md
```
Extract: title, description, motivasyon, yaklaşım

### Step 4: Create Task Directory

```bash
# Generate slug from title
SLUG=$(echo "<TITLE>" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# Ensure plugin data directory exists
mkdir -p ~/.claude/task-manager/tasks/{active,completed,cancelled,backlog,templates}

# Create task directory structure
mkdir -p ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>
mkdir -p ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>/subtasks
mkdir -p ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>/outputs
mkdir -p ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>/context
```

### Step 4.1: Initialize Context Files

Create initial context files using plugin templates:

```bash
# Create decisions.md from template
Copy: plugin/templates/decisions.md → ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>/context/decisions.md
Replace: {{TASK_ID}} with TASK-XXX

# Create research.md from template
Copy: plugin/templates/research.md → ~/.claude/task-manager/tasks/active/TASK-XXX-<SLUG>/context/research.md
Replace: {{TASK_ID}} with TASK-XXX
```

### Step 5: Generate task.md

Use template from plugin's `templates/task.md` and fill variables:

```markdown
# TASK-XXX: <Title>

## Meta
- **ID:** TASK-XXX
- **Oluşturulma:** <current datetime>
- **Durum:** pending
- **Son Güncelleme:** <current datetime>
- **Kaynak:** manual | jira:<TICKET-ID> | idea:<slug>

## Amaç
<Description or Jira summary>

## Kapsam
<If from Jira: extracted from description>
<If manual: to be defined>

## Plan
1. [ ] Initial analysis ← [NEXT]
2. [ ] Implementation
3. [ ] Testing
4. [ ] Review

## Current Position
<!-- This section is auto-updated to track exact resume point -->
**Phase:** Planning
**Current Step:** Initial analysis
**Last Action:** Task created
**Next Action:** Begin initial analysis

## Subtasklar
| ID | Başlık | Durum | Dosya |
|----|--------|-------|-------|
| - | - | - | - |

## Doküman Referansları
- None yet

## Context Files
<!-- Session-persistent context stored in context/ folder -->
- `context/research.md` - Research notes and findings
- `context/decisions.md` - Decision log with rationale

## İlerleme Notları
### <current date> <time>
- [CREATED] Task oluşturuldu
- [NEXT] Begin initial analysis

## Çıktılar
- None yet

## Kullanıcı Onayı
- [ ] Task tamamlandı onayı bekleniyor
```

**IMPORTANT:** The `Current Position` section and `[NEXT]` markers are critical for session recovery. Claude MUST update these after every significant step.

### Step 6: Update Index

Edit `~/.claude/task-manager/tasks/index.md`:
- Add new task to "Aktif Tasklar" table
- Update "Son güncelleme" date

### Step 7: Update Idea (if from-idea)

Edit `~/.claude/task-manager/tasks/backlog/<idea-slug>.md`:
- Add note: `[TASK'A DÖNÜŞTÜRÜLDÜ: TASK-XXX - <date>]`

### Step 8: Output Summary

```
## Task Created

**ID:** TASK-XXX
**Title:** <title>
**Location:** ~/.claude/task-manager/tasks/active/TASK-XXX-<slug>/task.md
**Source:** <manual|jira:<ID>|idea:<slug>>

Next steps:
- Run `/task-manager:continue TASK-XXX` to start working on this task
- Or run `/ai-developer <JIRA-ID>` if this is a Jira-linked development task
```

---

## Constants

```
PLUGIN_DATA: ~/.claude/task-manager/
TASK_ROOT: ~/.claude/task-manager/tasks/
ACTIVE_DIR: ~/.claude/task-manager/tasks/active/
COMPLETED_DIR: ~/.claude/task-manager/tasks/completed/
BACKLOG_DIR: ~/.claude/task-manager/tasks/backlog/
TEMPLATE_DIR: ~/.claude/task-manager/tasks/templates/
INDEX_FILE: ~/.claude/task-manager/tasks/index.md
```

**Note:** All paths are relative to user's home directory, not the current project.

---

## Error Handling

| Scenario | Action |
|----------|--------|
| No arguments provided | Show usage help |
| Jira ticket not found | Stop, report error |
| Idea file not found | Stop, report error |
| Directory already exists | Ask user: overwrite or choose new slug? |

---

## Examples

### Example 1: From Title
```
User: /task-manager:create "Add dark mode support"

Output:
## Task Created
**ID:** TASK-012
**Title:** Add dark mode support
**Location:** ~/.claude/task-manager/tasks/active/TASK-012-add-dark-mode-support/task.md
**Source:** manual
```

### Example 2: From Jira
```
User: /task-manager:create --from-jira AT-14500

Output:
## Task Created
**ID:** TASK-013
**Title:** Implement webhook retry mechanism
**Location:** ~/.claude/task-manager/tasks/active/TASK-013-implement-webhook-retry-mechanism/task.md
**Source:** jira:AT-14500
```

### Example 3: From Idea
```
User: /task-manager:create --from-idea continuous-profiling

Output:
## Task Created
**ID:** TASK-014
**Title:** Implement Continuous Profiling
**Location:** ~/.claude/task-manager/tasks/active/TASK-014-implement-continuous-profiling/task.md
**Source:** idea:continuous-profiling

Note: Original idea file updated with task reference.
```
