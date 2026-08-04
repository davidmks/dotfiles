---
name: start-ticket
description: Read a Notion ticket, plan the implementation, name the branch, then build it. Use when the user runs /start-ticket with a ticket URL or ID, or asks to start work on a ticket in a fresh worktree.
argument-hint: "<notion-url-or-ticket-id>"
allowed-tools: "Bash Read Write Edit Glob Grep TodoWrite EnterPlanMode ExitPlanMode mcp__claude_ai_Notion__notion-fetch mcp__claude_ai_Notion__notion-search"
---

# Start a ticket

**Input**: `$ARGUMENTS` — Notion ticket URL or ID (e.g. `GEN-14742`).

`wt` opens this session in a fresh worktree named after the ticket ID. The branch still carries that
placeholder name until step 4 replaces it.

## Steps

### 1. Enter plan mode

Call `EnterPlanMode` before anything else. The work is not approved yet, and step 3 needs the plan to
exist before the branch can be named.

### 2. Read the ticket

Fetch it with `mcp__claude_ai_Notion__notion-fetch`. If `$ARGUMENTS` is a bare ID rather than a URL,
find the page with `mcp__claude_ai_Notion__notion-search` first.

Use those tool names. Do not use `mcp__notionMCP__*` — that server is not configured on this machine,
though several team skills still reference it.

### 3. Plan

Research the codebase and write the implementation plan as normal.

### 4. Propose the branch name

End the plan with the branch name you propose:

```
<prefix>/<TICKET-ID>-<slug>
```

The prefix describes **what the change does to the code**: `feat` for new capability, `fix` for
something broken, `refactor` for restructuring with no behaviour change, `chore` for upkeep,
investigation, or config.

Ignore the ticket's `Type` property. It is set when the ticket is filed, before anyone has decided
what the change will be, and it matches the prefix actually committed only about two thirds of the
time. The plan you just wrote is better evidence.

Slug: two to four words, kebab-case. Drop any `Parent >` breadcrumb and bracketed prefixes like
`[FOO]`.

### 5. Rename, then implement

Once the plan is approved, before writing any code:

```bash
sarj rename <prefix>/<TICKET-ID>-<slug>
```

That renames the branch, the worktree directory, and the tmux session together. Then implement the
plan.

## Notes

Renaming is safe with uncommitted changes, and tmux keeps tracking the directory across the move, so
there is no reason to defer it until the work is done.
