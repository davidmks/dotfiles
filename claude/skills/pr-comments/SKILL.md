---
name: pr-comments
description: >-
  Read the review comments left on a PR by bots and colleagues, judge each one
  against the actual code, and report which are worth acting on. Use whenever the
  user asks about feedback on their PR — "check the PR comments", "did the bots
  find anything", "any review feedback", "address the comments", "what did
  CodeRabbit/Sourcery/Copilot say" — even if they don't name the skill. This is
  for reacting to what other people said; use quick-review instead when the user
  wants your own fresh opinion on the diff.
allowed-tools: "Bash Read Grep Glob Edit Write"
---

# PR Comments

Someone else reviewed this PR. Find out what they said, work out which parts are
actually right, and report before touching anything.

## 1. Fetch

Default to the current branch's PR (`gh pr view --json number`), or use the
number the user gave you. Comments live in three places and `gh pr view
--comments` only reaches one, so pull all three in a single call. `{owner}` and
`{repo}` resolve from the current repo:

```bash
gh api graphql -F owner='{owner}' -F repo='{repo}' -F num=NUM -f query='
query($owner:String!,$repo:String!,$num:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$num){
      comments(first:50){nodes{author{login} body}}
      reviews(first:50){nodes{author{login} state body}}
      reviewThreads(first:100){nodes{
        isResolved isOutdated path line
        comments(first:20){nodes{author{login} body}}
      }}
    }
  }
}' --jq '.data.repository.pullRequest | {
  threads: [.reviewThreads.nodes[] | select(.isResolved | not)],
  reviews: [.reviews.nodes[] | select(.body != "")],
  comments: .comments.nodes
}'
```

The `--jq` drops resolved threads before they reach context — on a PR with a long
settled history that is most of the payload. Bot bodies are verbose, so expect
this to cost real tokens on a busy PR.

Then drop the user's own comments unless one reads like a note-to-self, and
collapse duplicates — two bots on the same line is one finding. `isOutdated`
means the code moved underneath the comment: check whether it still applies
rather than dropping it. If nothing survives, say so and stop.

## 2. Judge each one against the code

Open the file each comment points at and read enough around it to decide for
yourself. Follow the callers if the claim is about behaviour. Check `CLAUDE.md`
and anything under `.claude/` if it's about project convention.

Review bots pattern-match. They flag things that look wrong in isolation and are
fine in context: a check that seems missing but happens upstream, a bug in a
branch the data can't reach, a convention complaint that doesn't match how this
repo actually does it. Confident wording is not evidence. If you relay the list
without checking it, you've saved no work and added the risk that a wrong
suggestion gets applied.

Land on one of three verdicts:

- **Valid** — the claim holds and there's a clear fix.
- **Invalid** — it doesn't hold. Name the specific code that makes it wrong;
  "the bot missed something" is not a reason.
- **Needs the user's call** — it holds, but the fix is scope, taste, a tradeoff,
  or separate-PR material.

Unsure means the third one, not a guess. Being wrong in the valid column is worse
than admitting doubt.

## 3. Report, then stop

Group by verdict, valid first. Per finding: source, file and line, the claim in
one line, the fix in one line.

Then stop. No edits, no commit, no push. The user runs this to decide what to do,
so a report that arrives after the edits is worthless to them. This holds when
every finding looks obviously correct, and in an auto-approving session — the
stop is the point of the skill.

Never reply to a comment, resolve a thread, approve, request changes, or merge.
Those go out under the user's name.

## 4. Apply what they pick

Change only what they named, including leaving alone a finding you argued was
valid. If a fix surfaces a related problem, mention it rather than quietly
widening the change.
