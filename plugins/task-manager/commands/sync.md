---
description: Synchronize ~/.claude/task-manager/tasks/index.md with actual task folders
argument-hint: [--dry-run] [--fix]
---

# Task Sync Workflow

Version: 1.0.0
Last Updated: 2025-01-18

## Purpose

Ensure `~/.claude/task-manager/tasks/index.md` is synchronized with the actual task folders in `~/.claude/task-manager/tasks/active/`, `~/.claude/task-manager/tasks/completed/`, and `~/.claude/task-manager/tasks/cancelled/`. Detects discrepancies and optionally fixes them.

---

## Input Options

```
/task-manager:sync              # Check and report discrepancies
/task-manager:sync --dry-run    # Same as default, just check
/task-manager:sync --fix        # Automatically fix discrepancies
```

---

## Execution Steps

### Step 1: Scan Actual Folders

```bash
# Get all active tasks
ACTIVE_TASKS=$(ls -d ~/.claude/task-manager/tasks/active/TASK-* 2>/dev/null | xargs -n1 basename)

# Get all completed tasks
COMPLETED_TASKS=$(ls -d ~/.claude/task-manager/tasks/completed/TASK-* 2>/dev/null | xargs -n1 basename)

# Get all cancelled tasks
CANCELLED_TASKS=$(ls -d ~/.claude/task-manager/tasks/cancelled/TASK-* 2>/dev/null | xargs -n1 basename)
```

### Step 2: Parse Current index.md

```bash
Read: ~/.claude/task-manager/tasks/index.md
```

Extract:
- Tasks in "Aktif Tasklar" table
- Tasks in "Son Tamamlanan Tasklar" table
- Tasks in "İptal Edilen Tasklar" table

### Step 3: Compare and Detect Discrepancies

| Discrepancy Type | Description |
|------------------|-------------|
| `MISSING_IN_INDEX` | Task folder exists but not in index |
| `ORPHAN_IN_INDEX` | Task in index but folder doesn't exist |
| `WRONG_SECTION` | Task in wrong section (e.g., completed task in active) |
| `STALE_STATUS` | Task status in index doesn't match task.md |
| `MISSING_LINK` | Link in index is broken |

### Step 4: Read Task Details

For each detected task folder, read task.md to get:
- Title
- Status (durum)
- Creation date
- Last update

### Step 5: Generate Report

```markdown
## Task Sync Report

**Scan Time:** <current datetime>
**Index File:** ~/.claude/task-manager/tasks/index.md

### Summary
| Category | Count |
|----------|-------|
| Active Tasks (folders) | X |
| Active Tasks (index) | Y |
| Completed Tasks (folders) | A |
| Completed Tasks (index) | B |
| Discrepancies Found | N |

### Discrepancies

#### Missing in Index
Tasks that exist in folders but not in index:
| Task | Location | Status |
|------|----------|--------|
| TASK-012 | ~/.claude/task-manager/tasks/active/TASK-012-new-feature/ | pending |

#### Orphaned in Index
Tasks in index but folders don't exist:
| Task | Index Section | Expected Location |
|------|---------------|-------------------|
| TASK-999 | Aktif Tasklar | ~/.claude/task-manager/tasks/active/TASK-999-*/ |

#### Wrong Section
Tasks in wrong index section:
| Task | Current Section | Correct Section |
|------|-----------------|-----------------|
| TASK-008 | Aktif Tasklar | Son Tamamlanan |

#### Status Mismatch
Tasks with stale status in index:
| Task | Index Status | Actual Status |
|------|--------------|---------------|
| TASK-007 | pending | in_progress |

---

### Recommended Actions

1. Add TASK-012 to Aktif Tasklar
2. Remove TASK-999 from index (orphan)
3. Move TASK-008 to Son Tamamlanan
4. Update TASK-007 status to in_progress

Run `/task-manager:sync --fix` to apply these changes automatically.
```

### Step 6: Apply Fixes (if --fix)

If `--fix` flag provided:

#### 6.1 Add Missing Tasks

For each `MISSING_IN_INDEX`:
- Read task.md for details
- Add to appropriate section in index.md

#### 6.2 Remove Orphans

For each `ORPHAN_IN_INDEX`:
- Remove row from index.md
- Note: Does NOT delete folders (safe operation)

#### 6.3 Move Wrong Section

For each `WRONG_SECTION`:
- Remove from current section
- Add to correct section

#### 6.4 Update Status

For each `STALE_STATUS`:
- Update status field in index row

#### 6.5 Update Timestamp

```markdown
Son güncelleme: <current date>
```

### Step 7: Output Result

**If --dry-run or no flag:**
```markdown
## Sync Check Complete

Found X discrepancies. Run `/task-manager:sync --fix` to resolve.
```

**If --fix:**
```markdown
## Sync Complete

**Applied Changes:**
- Added 2 tasks to index
- Removed 1 orphan reference
- Moved 1 task to correct section
- Updated 3 task statuses

Index is now synchronized with task folders.
```

---

## Index Format Reference

The index.md should follow this structure:

```markdown
# Task Index

Son güncelleme: YYYY-MM-DD

## Aktif Tasklar
| ID | Başlık | Durum | Oluşturulma | Link |
|----|--------|-------|-------------|------|
| TASK-001 | Title | status | YYYY-MM-DD | [link](active/TASK-001-.../task.md) |

## Son Tamamlanan Tasklar
| ID | Başlık | Tamamlanma | Link |
|----|--------|------------|------|
| TASK-005 | Title | YYYY-MM-DD | [link](completed/TASK-005-.../task.md) |

## İptal Edilen Tasklar
| ID | Başlık | İptal Tarihi | Sebep | Link |
|----|--------|--------------|-------|------|
| - | - | - | - | - |

---
**Not:** Bu dosya Claude tarafından otomatik güncellenir.
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| index.md doesn't exist | Create from scratch with current folders |
| Task folder has no task.md | Skip, report as warning |
| index.md is malformed | Backup and regenerate |
| Permission error | Report and stop |

---

## Example Output

```
User: /task-manager:sync

## Task Sync Report

**Scan Time:** 2025-01-18 23:55:00
**Index File:** ~/.claude/task-manager/tasks/index.md

### Summary
| Category | Count |
|----------|-------|
| Active Tasks (folders) | 7 |
| Active Tasks (index) | 7 |
| Completed Tasks (folders) | 4 |
| Completed Tasks (index) | 4 |
| Discrepancies Found | 0 |

Index is synchronized. No action needed.
```
