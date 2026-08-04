---
name: start-ticket
description: Read a Notion ticket and explain it in plain language. Use when the user runs /start-ticket with a ticket URL or ID, or asks what a ticket is about. Explaining only — it does not plan or write code.
argument-hint: "<notion-url-or-ticket-id>"
allowed-tools: "mcp__claude_ai_Notion__notion-fetch mcp__claude_ai_Notion__notion-search mcp__claude_ai_Notion__notion-get-comments"
disallowed-tools: "Edit Write NotebookEdit"
---

# Read a ticket

**Input**: `$ARGUMENTS` — Notion ticket URL or ID (e.g. `GEN-14742`).

## Steps

### 1. Fetch the ticket

Fetch it with `mcp__claude_ai_Notion__notion-fetch`, passing `include_discussions: true`. If
`$ARGUMENTS` is a bare ID rather than a URL, find the page with `mcp__claude_ai_Notion__notion-search`
first.

Use those tool names. Do not use `mcp__notionMCP__*` — that server is not configured on this machine,
though several team skills still reference it.

### 2. Read the comments

If the fetch reports discussions, read them with `mcp__claude_ai_Notion__notion-get-comments`, passing
`include_all_blocks: true` and `include_resolved: true`. Comments often carry a decision that
contradicts the ticket body, so treat them as newer than the description.

### 3. Explain it

Write a concise bullet list in plain, human language: what is being asked, why it is wanted, and what it
touches. Explain any domain term the ticket takes for granted. Where the ticket is vague, silent, or
contradicts its own comments, say so instead of smoothing it over.

Stop there. End the turn and wait. Do not research the codebase, plan, or touch any file.
