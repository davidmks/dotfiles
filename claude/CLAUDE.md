# Global CLAUDE.md

## Writing style

Applies to all output, not just code and comments.

- Plain, everyday language. Say it the obvious way, not the clever way.
- Short sentences. Stop once the point is clear.
- Clarity beats brevity. Stop when it can't be misread, not when it's shortest.
- Avoid jargon; if a domain term is needed, explain it once in plain words.

These are mechanical. Check them every time:

- Never use the em dash character. Use a comma, period, colon, or hyphen instead.
- Never weaken or strengthen a hedge: "may have failed" does not become "failed".
- Active voice, name the actor: "the agent deletes the file", not "the file is deleted".
- Use the verb, not the noun form: "analyze the log", not "perform an analysis of the log".
- Plain verbs, not phrasal ones: start, contact, read. Not spin up, reach out, dive into.
- No marketing adjectives: seamless, robust, powerful, blazing-fast. Delete them, or give the number.
- One name per thing. Don't rotate check/verify/confirm for the same action.

## Commits

- Follow conventional commits: `type(scope): description`
- Use atomic commits: one logical change per commit
- NEVER add co-author lines, "Co-Authored-By", or "Generated with Claude"

## Comments & Docstrings

Write for someone who doesn't know the code or the domain, including your future self.

- Comments explain _why_, not _what_, and only when the code can't say it.
- Keep comments timeless: no session, ticket, or task references.
- Write docstrings from the caller's view: behavior, assumptions, side effects, and exceptions when not obvious.
