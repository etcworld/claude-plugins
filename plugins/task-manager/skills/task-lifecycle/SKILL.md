---
name: task-lifecycle
version: 1.0.1
description: Automatic task context detection, session continuity, and progress persistence
triggers:
  - "continue"
  - "resume"
  - "what was I working on"
  - "last task"
  - "devam"
  - "kaldığım yer"
---

# Task Lifecycle Skill

Automatically detects task-related context, provides session continuity, and ensures progress is persistently saved to disk.

---

## CRITICAL: Session-Safe Working Protocol

### Golden Rule
**All progress MUST be written to `~/.claude/task-manager/tasks/` folder, NOT kept in memory.**

When working on a task, Claude MUST:
1. **Read context from disk** - Never rely on conversation history alone
2. **Write progress to disk after each significant step** - Context can be cleared anytime
3. **Update task.md before moving to next step** - Single source of truth
4. **Store large context in `context/` folder** - Keep task.md focused

### Progress Checkpoint Triggers

Save progress to disk IMMEDIATELY after:
- [ ] Completing any plan item
- [ ] Finishing a subtask
- [ ] Making an important decision
- [ ] Discovering new information
- [ ] Writing/modifying code
- [ ] Before any potentially long operation
- [ ] When user says "save", "kaydet", "checkpoint"

---

## Active Task Working Mode

When a task is active (after `/task-manager:continue`), Claude operates in **Task Mode**:

### Task Mode Rules

1. **Always know the active task**: Keep TASK-ID in working memory
2. **Read before write**: Always read current task.md before making updates
3. **Atomic progress updates**: Update task.md after each completed step
4. **Use context/ for large data**: Code snippets, research, API responses go to context/
5. **Use outputs/ for deliverables**: Final files, exports, results go to outputs/

### Progress Update Format

After each significant step, update task.md:

```markdown
## İlerleme Notları
### YYYY-MM-DD HH:MM
- [COMPLETED] <what was done>
- [DECISION] <decision made and why>
- [NEXT] <immediate next step>
- [BLOCKER] <if any blockers exist>
```

### Plan Item Updates

When completing a plan item:
```markdown
## Plan
1. [x] Initial analysis ✅ (completed: 2025-01-18)
2. [x] Implementation ✅ (completed: 2025-01-18)
3. [ ] Testing ← CURRENT
4. [ ] Review
```

---

## Context Folder Usage

The `context/` folder stores session-independent information:

```
~/.claude/task-manager/~/.claude/task-manager/tasks/active/TASK-XXX-slug/
├── task.md              # Main task file (always up-to-date)
├── context/
│   ├── research.md      # Research notes, findings
│   ├── decisions.md     # Decision log with rationale
│   ├── code-snippets.md # Relevant code excerpts
│   ├── api-responses/   # API response samples
│   └── references/      # External references, docs
├── sub~/.claude/task-manager/tasks/
│   └── 001-*.md         # Individual subtask files
└── outputs/
    └── *                # Deliverable files
```

### When to Write to Context

- **research.md**: After investigating codebase, reading docs
- **decisions.md**: After making architectural/design decisions
- **code-snippets.md**: When analyzing specific code sections
- Store files that would be expensive to regenerate

---

## Session Boundary Protocol

### When Context is About to Fill

Claude should proactively:
1. Update task.md with current progress
2. Write any in-memory context to context/ folder
3. Mark current step clearly with `[IN_PROGRESS]`
4. Add note: "Session may end soon, context saved to disk"

### When New Session Starts

On detecting a new session (or `/task-manager:continue`):

1. **Scan active tasks**: `ls ~/.claude/task-manager/~/.claude/task-manager/tasks/active/`
2. **Find most recent**: Check modification times
3. **Read full context**:
   - `task.md` for status and progress
   - `context/*.md` for research and decisions
   - `sub~/.claude/task-manager/tasks/*.md` for subtask states
4. **Present resume point**
5. **Continue from last `[IN_PROGRESS]` or `[NEXT]` marker**

---

## Auto-Detection Triggers

### English Triggers
- "continue" - User wants to continue work
- "resume" - User wants to resume a task
- "what was I working on" - User asks about previous work
- "last task" - User references the last task
- "pick up where I left off" - Session continuity request

### Turkish Triggers
- "devam" - Continue
- "kaldığım yer" - Where I left off
- "son task" - Last task
- "ne üzerinde çalışıyordum" - What was I working on

---

## Session Recovery Flow

When triggered:

```markdown
## Session Recovery

Reading from: ~/.claude/task-manager/~/.claude/task-manager/tasks/active/

### Active Tasks Found
| ID | Title | Status | Last Updated |
|----|-------|--------|--------------|
| TASK-007 | Feature Implementation | in_progress | 2025-01-18 14:30 |

### TASK-007 Context Loaded

**From task.md:**
- Status: in_progress
- Current Phase: Implementation
- Last Progress: "Completed API endpoint, starting tests"

**From context/:**
- research.md: API documentation notes
- decisions.md: Chose REST over GraphQL

**Resume Point:**
```markdown
[NEXT] Write unit tests for UserController
```

Would you like to continue from this point?
```

---

## Checkpoint Command

User can explicitly request a checkpoint:

```
User: "checkpoint" / "save progress" / "kaydet"

Claude Response:
## Checkpoint Saved

**Task:** TASK-007
**Time:** 2025-01-18 15:30:00

**Updated Files:**
- ~/.claude/task-manager/~/.claude/task-manager/tasks/active/TASK-007-.../task.md
  - Progress notes updated
  - Plan items marked
- ~/.claude/task-manager/~/.claude/task-manager/tasks/active/TASK-007-.../context/decisions.md
  - New decision recorded

**Current State:**
- Completed: Items 1-3
- In Progress: Item 4 (Testing)
- Next: Write integration tests

Context is now persisted. Safe to end session.
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| No active tasks found | Suggest creating a new task |
| ~/.claude/task-manager/tasks/ directory missing | Initialize task structure |
| Corrupted task.md | Report error, offer to recreate from context/ |
| Context lost | Rebuild from context/ folder files |
| Subtask out of sync | Run `/task-manager:sync` |

---

## Best Practices for Claude

1. **Never trust memory alone** - Always verify against disk
2. **Checkpoint frequently** - Better too often than too late
3. **Keep task.md concise** - Move details to context/
4. **Use clear markers** - `[COMPLETED]`, `[IN_PROGRESS]`, `[NEXT]`, `[BLOCKER]`
5. **Timestamp everything** - Helps with session recovery
6. **Announce saves** - Let user know when progress is persisted
