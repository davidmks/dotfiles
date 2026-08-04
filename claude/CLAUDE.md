# Global CLAUDE.md

## Writing style

Applies to all output, not just code and comments.

- Plain, everyday language.
- Short sentences.
- Say it the obvious way, not the clever way.
- Don't try to sound smart, just say things simply.
- Stop once the point is clear.
- Avoid jargon; if a domain term is needed, explain it once in plain words.
- Never use the em dash character. Use a comma, period, colon, or hyphen instead.

## Commits

- Follow conventional commits: `type(scope): description`
- Use atomic commits: one logical change per commit
- NEVER add co-author lines, "Co-Authored-By", or "Generated with Claude"

## Comments & Docstrings

Write for someone who doesn't know the code or the domain, including your future self.

- Comments explain _why_, not _what_, and only when the code can't say it.
- Keep comments timeless: no session, ticket, or task references.
- Write docstrings from the caller's view: behavior, assumptions, side effects, and exceptions when not obvious.
