---
name: plan-ticket
description: Plan an approved ticket, name the branch, rename the worktree branch, then build it. Use when the user asks to plan a ticket, or says to start building after a ticket briefing.
argument-hint: "<ticket-id>"
allowed-tools: "Bash Read Write Edit Glob Grep TodoWrite EnterPlanMode ExitPlanMode"
---

# Plan a ticket

`wt` names the worktree and its branch after the ticket ID. That branch name is a placeholder until
step 3 replaces it.

If the ticket has not been read in this session, run `/start-ticket` first. Planning from a ticket ID
alone means planning without the comments.

## Steps

### 1. Enter plan mode

Call `EnterPlanMode` before anything else. The work is not approved yet, and step 3 needs the plan to
exist before the branch can be named.

### 2. Plan

Research the codebase and write the implementation plan as normal.

Start by reading all of `.claude/rules/*.md` (~270 lines). They are path-scoped, so the harness injects
one only once you open a matching file with Read: too late to shape a plan you already wrote, and not at
all for files you inspect through `grep` or `sed`.

Nothing surfaces `docs/`. Grep `docs/architecture-decision-records/` for the subdomain you are changing,
and read `docs/guidelines/Engineering-guidelines.md` — its 300-line ceiling decides whether the plan is
one PR or a stack.

### 3. Propose the branch name

End the plan with the branch name you propose:

```
<prefix>/<TICKET-ID>-<slug>
```

The prefix describes **what the change does to the code**: `feat` for new capability, `fix` for
something broken, `refactor` for restructuring with no behaviour change, `chore` for upkeep,
investigation, or config.

Ignore the ticket's `Type` property. It is set when the ticket is filed, before anyone has decided what
the change will be, and it matches the prefix actually committed only about two thirds of the time. The
plan you just wrote is better evidence.

Slug: two to four words, kebab-case. Drop any `Parent >` breadcrumb and bracketed prefixes like `[FOO]`.

### 4. Rename, then implement

Once the plan is approved, before writing any code:

```bash
sarj rename --keep-path <prefix>/<TICKET-ID>-<slug>
```

That renames the branch and the tmux session.

## Notes

Renaming is safe with uncommitted changes, and safe after commits too — it moves the branch ref. Doing
it before the first edit is about not forgetting, not about safety.

`--keep-path` is required, not optional. Without it the worktree directory moves too, and this session
dies quietly: Claude Code records its project path once at startup, so every hook resolves to a path
that no longer exists and stops running. Nothing reports it as an error you can act on. The directory
keeps its ticket-ID name for the life of the worktree; `wt` finds it by ticket ID, not by directory
name.
