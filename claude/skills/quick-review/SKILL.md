---
name: quick-review
description: >-
  Plain common-sense review of the PR on the current branch — read the diff, use
  judgement, don't call other skills. Use when the user says "review this PR" and
  wants a quick pass, not a full review harness.
allowed-tools: "Bash Read Grep Glob"
---

# Quick Review

Review the PR on the current branch. Don't call any other skills. Just read the
diff and think.

## Steps

1. Get the diff. First find the branch this PR targets — don't assume `main`.
   Check the remote default with `git symbolic-ref refs/remotes/origin/HEAD`, and
   if the branch was cut from something else, use that. Then get the base with
   `git merge-base HEAD origin/<target>` and run `git diff <base>...HEAD`.

2. Read `CLAUDE.md` and anything under `.claude/` that looks like project rules.

3. Don't stop at the diff. It shows what changed, not whether it's right. Open the
   full files, read the functions the changes live in, follow the callers of
   anything changed, and check whether new code reinvents a pattern that already
   exists elsewhere. The branch is checked out — use the whole tree.

## What to check

- **Project rules.** Does the PR follow what's in CLAUDE.md and the rules files?
  Call out anything that doesn't.
- **Patterns.** Does it match how the rest of the codebase does things? If it
  invents a new way to do something that already has a pattern, say so.
- **Simpler?** If something could be shorter, clearer, or reuse existing code,
  suggest it.
- **Would you do it differently?** If yes, say what and why.
- **Wrong or dangerous.** Flag bugs, footguns, security issues, or anything that
  could break.

## Output

Read-only. Don't edit, commit, or push — just report what you found.

Group findings by the sections above. Skip a section if there's nothing to say.
Lead with the dangerous/incorrect stuff. Be specific: point at the file and line.
